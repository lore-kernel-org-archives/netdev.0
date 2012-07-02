From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ieee802154: sparse warnings: make symbols
 static
Date: Mon, 02 Jul 2012 09:09:02 +0200
Message-ID: <1341212942.5269.10.camel@edumazet-glaptop>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341209912-6030-2-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341211072.5269.0.camel@edumazet-glaptop>
	 <1341211476.5269.2.camel@edumazet-glaptop>
	 <1341211751.5269.6.camel@edumazet-glaptop>
	 <CAJmB2rDB6McXg=O_z-M3xFa0OrB5hkTWT=ZHM975GDTPvuGjtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dbaryshkov@gmail.com
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57275 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab2GBHJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 03:09:04 -0400
Received: by eeit10 with SMTP id t10so1930211eei.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 00:09:03 -0700 (PDT)
In-Reply-To: <CAJmB2rDB6McXg=O_z-M3xFa0OrB5hkTWT=ZHM975GDTPvuGjtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 10:53 +0400, Alexander Smirnov wrote:
> Dear Eric,
> 
> >> > static DEFINE_SPINLOCK(flist_lock);
> >>
> >>
> >> and of course commit 768f7c7c121e80f4 (6lowpan: add missing
> >> spin_lock_init() ) must be reverted.
> >
> > You should validate this code with LOCKDEP
> >
> > lowpan_dellink() does a spin_lock(&flist_lock);
> > while same lock can be taken by lowpan_fragment_timer_expired() from
> > timer irq, -> deadlock.
> >
> > del_timer() probably needs a del_timer_sync() too
> >
> 
> Thanks a lot for the hints!

While you are changing this code, please add in
lowpan_alloc_new_frame() :

- use netdev_alloc_skb_ip_align() instead of alloc_skb() to get some
extra headroom in case we need to forward this frame in a tunnel or
something...

- initialize frame->lock
