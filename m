From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 17:10:19 -0400
Message-ID: <AANLkTimWaULcbxkUh5aCsM+6fWPaTM8CkZZh2hB_cQ3-@mail.gmail.com>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net> <1282596243.2378.327.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	acme@redhat.com, Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:54622 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335Ab0HWVKk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 17:10:40 -0400
Received: by qyk33 with SMTP id 33so5830712qyk.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 14:10:39 -0700 (PDT)
In-Reply-To: <1282596243.2378.327.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Answering two of you...

On Mon, Aug 23, 2010 at 4:44 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:

> Le lundi 23 ao=FBt 2010 =E0 21:00 +0200, Hagen Paul Pfeifer a =E9crit=
 :

>> This patch provides a sysctl interface for the administrator to glob=
ally
>> enable or disable TCP quick ACKs. Short lived protocols like HTTP wi=
ll
>> save a non unimportant portion of packets!

A year and a half ago, we merged a patch to tune the delayed ack
behavior.  While the proof of concept was a sysctl interface that a
relative novice to the TCP code like myself could write, the consensus
was that we already had a glut of TCP sysctls, and there was a
potential benefit to doing it on a per-route basis, so we could both
make the feature more flexible and avoid sysctl pollution by making it
a per-route tunable.  I think all of the same arguments apply to this
feature, as well as the argument that it surely makes sense to be
tuning delayed ack and quick ack in the same place.  I'm CCing acme,
because he wrote the final patch.

> What about dccp using this function ?

Also probably of interest to acme.

> I thought setsockopt(TCP_QUICKACK) was already available for this
> optimization ?

As with the delayed ack patch, modifying the application is not always
practical.  It's extremely helpful for an administrator to be able to
turn this on with a few keystrokes when performance starts suffering,
since patching the app (or multiple apps), validating the changes,
etc. could take months or years.

-- Chris
