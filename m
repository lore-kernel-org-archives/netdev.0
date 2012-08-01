From: "Tobias S. Josefowitz" <t.josefowitz@gmail.com>
Subject: Re: binding UDP port 0 with SO_REUSEADDR
Date: Wed, 1 Aug 2012 21:38:53 +0200
Message-ID: <CAEZM=bPqOgRUvUKfdYkrVXoWin+SMft0GK67hqsGhBD6nocryA@mail.gmail.com>
References: <CAEZM=bNdyZoTiGYwNM_3v+ro7dEn0q9aTo4040tBDqDSH3HOXg@mail.gmail.com>
	<1343847776.21269.797.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33375 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755739Ab2HATiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 15:38:54 -0400
Received: by obbuo13 with SMTP id uo13so12641107obb.19
        for <netdev@vger.kernel.org>; Wed, 01 Aug 2012 12:38:54 -0700 (PDT)
In-Reply-To: <1343847776.21269.797.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 1, 2012 at 9:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> And why are you using SO_REUSEADDR on UDP unicast sockets ?

Simple. This happens in a "scripting" language. The wrapper code
assumes that it is better to set SO_REUSEADDR than not (which might be
argued, but backwards-compat can be nice) and at the time the code was
written the author must have assumed that even if the 'user' aka
programmer wants to bind to port 0, SO_REUSEADDR doesn't hurt, because
port 0 implicitly meant "please, a free one".

> I mean, this is exactly saying " By using this REUSEADDR, I am allowing
> this port being used by another process, even from another user"

I know. Still, while binding port 0 means "give me any port", I'm
quite sure most people would assume they get a free one. And maybe,
for whatever reasons, you want to share your random port later and
need SO_REUSEADDR because of that. A usecase where someone wants a
randomly chosen free or used port does not come to my mind, though.

Of course, I'm not relying on the kernel to revert back, I adapted the
wrapper code I mentioned above. I still felt like mentioning that it
was kind of unexpected, that's all.

Best,

Tobi
