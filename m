From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: add pfmemalloc check in sk_add_backlog()
Date: Fri, 02 Oct 2015 02:38:21 -0700
Message-ID: <1443778701.32531.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443577945.32531.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150929.215607.1418732892830129304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gthelen@google.com, mhocko@suse.com,
	mgorman@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34151 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbbJBJiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 05:38:23 -0400
Received: by padhy16 with SMTP id hy16so102648133pad.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 02:38:23 -0700 (PDT)
In-Reply-To: <20150929.215607.1418732892830129304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-29 at 21:56 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 29 Sep 2015 18:52:25 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Greg reported crashes hitting the following check in __sk_backlog_rcv()
> > 
> > 	BUG_ON(!sock_flag(sk, SOCK_MEMALLOC)); 
> > 
> > The pfmemalloc bit is currently checked in sk_filter().
> > 
> > This works correctly for TCP, because sk_filter() is ran in
> > tcp_v[46]_rcv() before hitting the prequeue or backlog checks.
> > 
> > For UDP or other protocols, this does not work, because the sk_filter()
> > is ran from sock_queue_rcv_skb(), which might be called _after_ backlog
> > queuing if socket is owned by user by the time packet is processed by
> > softirq handler.
> > 
> > Fixes: b4b9e35585089 ("netvm: set PF_MEMALLOC as appropriate during SKB processing")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Greg Thelen <gthelen@google.com>
> 
> Applied, thanks Eric.
Hi David

I could not find this patch in any of your trees, would you take a
look ?

Thanks !
