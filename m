From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] udp: Fix the SNMP counter of UDP_MIB_INDATAGRAMS
Date: Sat, 01 Nov 2008 21:35:29 -0700 (PDT)
Message-ID: <20081101.213529.60503932.davem@davemloft.net>
References: <490C1CA7.3070201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751580AbYKBEfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:35:53 -0400
In-Reply-To: <490C1CA7.3070201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Sat, 01 Nov 2008 17:08:55 +0800

> @@ -158,6 +159,8 @@ try_again:
>  	else if (copied < ulen)
>  		msg->msg_flags |= MSG_TRUNC;
>  +	is_udp4 = (skb->protocol == htons(ETH_P_IP));
> +
>  	/*
>  	 * If checksum is needed at all, try to do it while copying the
>  	 * data.  If the data is truncated, or if we only want a partial
 ...
>  	sock_recv_timestamp(msg, sk, skb);
>  @@ -196,7 +204,7 @@ try_again:
>  		sin6->sin6_flowinfo = 0;
>  		sin6->sin6_scope_id = 0;
>  -		if (skb->protocol == htons(ETH_P_IP))
> +		if (is_udp4)
>  			ipv6_addr_set(&sin6->sin6_addr, 0, 0,

This patch is corrupted in ways I thought I would never see in my
entire life.  Congratulations!

Please clean this up and resubmit, along with your second patch of
this set.

Thanks.
