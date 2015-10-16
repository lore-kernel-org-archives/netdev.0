From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: add pfmemalloc check in sk_add_backlog()
Date: Fri, 16 Oct 2015 08:38:38 -0700
Message-ID: <1445009918.25595.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443577945.32531.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150929.215607.1418732892830129304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33962 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266AbbJPPik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 11:38:40 -0400
Received: by pacez2 with SMTP id ez2so7982006pac.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 08:38:40 -0700 (PDT)
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

This patch never reached a public net tree.

Should I respin it ?

Thanks !
