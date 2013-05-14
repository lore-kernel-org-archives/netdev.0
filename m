From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Mon, 13 May 2013 18:30:34 -0700
Message-ID: <1368495034.32106.1.camel@edumazet-glaptop>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
	 <1368447851.13473.119.camel@edumazet-glaptop>
	 <1368493940.30953.3.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Ward <david.ward@ll.mit.edu>,
	hayeswang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:55897 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779Ab3ENBai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 21:30:38 -0400
Received: by mail-pd0-f169.google.com with SMTP id bv13so4855009pdb.28
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 18:30:37 -0700 (PDT)
In-Reply-To: <1368493940.30953.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-14 at 09:12 +0800, Cong Wang wrote:
> On Mon, 2013-05-13 at 05:24 -0700, Eric Dumazet wrote:
> >         del_timer_sync(&app->join_timer);
> >  
> > -       spin_lock(&app->lock);
> > +       spin_lock_bh(&app->lock); 
> 
> But we just have removed the join timer before taking this spin lock, so
> it is not possible to race with timer, but we still have race condition
> with mrp_rcv() which is called in BH context too. However, this is not
> what Denys reported, so I have no idea on this.
> 

Thats a lockdep splat.

lockdep cannot know join timer wont fire again.
