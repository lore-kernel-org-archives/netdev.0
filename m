From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Mon, 23 Jul 2012 11:25:53 -0400
Message-ID: <CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	<1343020585.2626.10054.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:58554 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab2GWPZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 11:25:54 -0400
Received: by vbbff1 with SMTP id ff1so4773984vbb.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 08:25:53 -0700 (PDT)
In-Reply-To: <1343020585.2626.10054.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, Jul 23, 2012 at 1:16 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Hmm. This patches adds races, but also adds a good amount of memory on
> these servers with thousand of ppp devices, and 64 cpus.

I am curious if you can elaborate on what is racy about the patch, I
am still trying to learn.  I assumed (possibly incorrectly) that
because I was using percpu variables that the stats updates didn't
need any extra synchronization as any concurrent updates would be on
different cpus.

> I really doubt ppp is performance sensitive, it so doesnt need percpu
> counter.
>
> If you really want 64bits stats on ppp, use proper synchronization
> around u64 counters (but shared ones)

I will work on an updated patch without the percpu variables.  I
didn't really think about servers with many cpus and many ppp sessions
when I created the patch, I was mainly thinking about my Linksys
router and other simple clients.  Many of the other network drivers
use percpu variables for their stats so I just followed along.

Would proper synchronization in this case just be wrapping the updates
in a spin_lock/spin_unlock?


Kevin
