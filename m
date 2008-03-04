From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Mon, 3 Mar 2008 21:15:35 -0800
Message-ID: <20080303211535.03e3c81e@extreme>
References: <47BDC848.50607@cosmosbay.com>
	<20080226.182120.183405235.davem@davemloft.net>
	<47C92F49.4070100@cosmosbay.com>
	<20080303.205558.114610030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38357 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041AbYCDFPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 00:15:41 -0500
In-Reply-To: <20080303.205558.114610030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Mar 2008 20:55:58 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 01 Mar 2008 11:26:17 +0100
> 
> > You are absolutly right. We should guard against recursion, using a new field 
> > in "pcpu_lstats" (cheap access in a hot cache line as we have to update stats 
> > anyway)
>  ...
> > [PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
> 
> I'm willing to seriously entertain this change and stick it
> into net-2.6.26 if you will perform a reasonable deep stack
> test.
> 
> For example, create an XFS filesystem, and mount it NFS over
> loopback.  Then stress it like crazy.
> 
> See if this generates stack overflows or weird crashes.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Also (unrealistic) benchmarks often test loopback performance, so you
should also check for performance gains/losses in things like
netbench, netperf, tbench, etc.
