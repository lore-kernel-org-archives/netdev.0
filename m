From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Wed, 25 Jul 2012 16:50:09 +0200
Message-ID: <1343227809.2626.11159.camel@edumazet-glaptop>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	 <1343020585.2626.10054.camel@edumazet-glaptop>
	 <CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
	 <1343059184.2626.11027.camel@edumazet-glaptop>
	 <CABF+-6Vko_T2RCsk1KVouB8a+8Ms_aLEoA-Xet1nxB8bnZAxMA@mail.gmail.com>
	 <1343110954.2626.11040.camel@edumazet-glaptop>
	 <CABF+-6Wpn8yEvru1FDsaFbXYZ7tyeQqqbEU2VY8hLKvmXXFBXA@mail.gmail.com>
	 <1343189061.2626.11073.camel@edumazet-glaptop>
	 <CABF+-6VAWVM=Cpyjk4iTbG-bBfHUs_CfRhe7rXmxxiF_ZX7_OA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49513 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932943Ab2GYOuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 10:50:14 -0400
Received: by bkwj10 with SMTP id j10so588204bkw.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 07:50:12 -0700 (PDT)
In-Reply-To: <CABF+-6VAWVM=Cpyjk4iTbG-bBfHUs_CfRhe7rXmxxiF_ZX7_OA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 10:43 -0400, Kevin Groeneveld wrote:
> On Wed, Jul 25, 2012 at 12:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > It there are spinlocks already, why even adding u64_stats_sync ?
> 
> That is a good question I have already wondered about myself.
> 
> >include/linux/u64_stats_sync.h
> >
> >* 3) Write side must ensure mutual exclusion or one seqcount update could
> > *    be lost, thus blocking readers forever.
> > *    If this synchronization point is not a mutex, but a spinlock or
> > *    spinlock_bh() or disable_bh() :
> 
> It seems the u64_stats_sync requires some form of mutual exclusion.
> So why bother ever using it at all?  Maybe there are cases where the
> required mutual exclusion can be cheaper than a spinlock?  Maybe it is
> just to avoid the spinlocks on the read side of things?
> 
> I hope you don't mind all my questions...

u64_stats_sync is good for write sides without any locking,
for example using percpu data.

So if you use shared counters, u64_stats_sync has no value.
