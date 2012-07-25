From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Wed, 25 Jul 2012 10:43:36 -0400
Message-ID: <CABF+-6VAWVM=Cpyjk4iTbG-bBfHUs_CfRhe7rXmxxiF_ZX7_OA@mail.gmail.com>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	<1343020585.2626.10054.camel@edumazet-glaptop>
	<CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
	<1343059184.2626.11027.camel@edumazet-glaptop>
	<CABF+-6Vko_T2RCsk1KVouB8a+8Ms_aLEoA-Xet1nxB8bnZAxMA@mail.gmail.com>
	<1343110954.2626.11040.camel@edumazet-glaptop>
	<CABF+-6Wpn8yEvru1FDsaFbXYZ7tyeQqqbEU2VY8hLKvmXXFBXA@mail.gmail.com>
	<1343189061.2626.11073.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:53336 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933264Ab2GYOni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 10:43:38 -0400
Received: by vbbff1 with SMTP id ff1so621825vbb.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 07:43:37 -0700 (PDT)
In-Reply-To: <1343189061.2626.11073.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 25, 2012 at 12:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> It there are spinlocks already, why even adding u64_stats_sync ?

That is a good question I have already wondered about myself.

>include/linux/u64_stats_sync.h
>
>* 3) Write side must ensure mutual exclusion or one seqcount update could
> *    be lost, thus blocking readers forever.
> *    If this synchronization point is not a mutex, but a spinlock or
> *    spinlock_bh() or disable_bh() :

It seems the u64_stats_sync requires some form of mutual exclusion.
So why bother ever using it at all?  Maybe there are cases where the
required mutual exclusion can be cheaper than a spinlock?  Maybe it is
just to avoid the spinlocks on the read side of things?

I hope you don't mind all my questions...
