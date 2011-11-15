From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Tue, 15 Nov 2011 01:35:27 -0500 (EST)
Message-ID: <20111115.013527.2095109012737872896.davem@davemloft.net>
References: <4EBA2E30.8050102@cn.fujitsu.com>
	<20111109.155936.1972852290616131285.davem@davemloft.net>
	<4EC1FB5D.80705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618Ab1KOGfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 01:35:39 -0500
In-Reply-To: <4EC1FB5D.80705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Tue, 15 Nov 2011 13:40:45 +0800

> These days i am doing some ICMP tests and sadly found that wen can't update
> iph->daddr in ip_options_rcv_srr(), It's too early. When some exception
> ocurred later (eg. in ip_forward() when goto sr_failed) we need the ip header
> be identical to the original one as ICMP need it.
> 
> It seems we need rt->rt_dst in ip_forward_options() and ip_forward() instead
> of iph->daddr.

An alternative is to store the calculated destination address somewhere
in the IPCB(skb).
