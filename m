From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] IPv6: rt->n (neighbour in rt6_info)
 removal (TAKE 3)
Date: Thu, 17 Jan 2013 15:37:53 -0500 (EST)
Message-ID: <20130117.153753.1608817353719202851.davem@davemloft.net>
References: <50F837D5.4020505@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757044Ab3AQUh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 15:37:57 -0500
In-Reply-To: <50F837D5.4020505@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 18 Jan 2013 02:41:41 +0900

> This is "TAKE 3" of neighbour removal from rt6_info.
> 
> 2->3:
> - Removed "icmp6_dst_alloc() removal" patch.
>   This is nothing to do with this series.
> - Removed several unused variables, ifdefs, BUG_ONs.
> - Handled several comments from Cong Wang.
> - Reordered.

This series is almost perfect, great work.

In ip6_output you need to accomodate the fact that __neigh_create()
returns error pointers so it is not valid to simply use a NULL test on
'neigh'.

You'll need to use IS_ERR().  'neigh' can never be NULL here, it is
either a valid non-NULL pointer or a return value from
__neigh_create().
