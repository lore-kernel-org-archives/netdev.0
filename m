From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2.4.35.3] Fix the "InAddrErrors" increasing problem
Date: Mon, 22 Oct 2007 11:58:17 +0530
Message-ID: <OF2D84A661.11AB43B8-ON6525737C.002349E6-6525737C.00238C77@in.ibm.com>
References: <471C3E0B.2070602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP06.au.ibm.com ([202.81.18.175]:56828 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbXJVG3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 02:29:17 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9M6SxeY016910
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 16:28:59 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9M6T01m897118
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 16:29:00 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9M6ShcD010747
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 16:28:44 +1000
In-Reply-To: <471C3E0B.2070602@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gui Jianfeng wrote on 10/22/2007 11:37:07 AM:

> @@ -310,8 +310,12 @@ static inline int ip_rcv_finish(struct s
>      *   how the packet travels inside Linux networking.
>      */
>     if (skb->dst == NULL) {
> -      if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))
> -         goto drop;
> +      int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
dev);
> +      if (unlikely(err)) {
> +         if (err == -EHOSTUNREACH)
> +            IP_INC_STATS_BH(IpInAddrErrors);
> +      }
> +      goto drop;
>     }

Shouldn't the "goto drop" be inside the "if (unlikely(err)) {" case?
And normally it is nice to have a blank line after variable declaration.

- KK

