From: David Miller <davem@davemloft.net>
Subject: Re: fib6_del_route has redundant code
Date: Thu, 27 Dec 2007 21:18:08 -0800 (PST)
Message-ID: <20071227.211808.221171928.davem@davemloft.net>
References: <477353B6.6000102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750958AbXL1FSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 00:18:10 -0500
In-Reply-To: <477353B6.6000102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Thu, 27 Dec 2007 15:26:46 +0800

> I think the following code in fib6_del_route in the latest kernel is useless.
> 1125         if (fn->leaf == NULL && fn->fn_flags&RTN_TL_ROOT)
> 1126                 fn->leaf = &ip6_null_entry;
> 
> ip6_null_entry will never be unlinked from fn->leaf now, that is,
> fn->leaf == NULL will never meet.

I think you are right, but if it is true the next block of
code is dead too:

	/* If it was last route, expunge its radix tree node */
	if (fn->leaf == NULL) {
		fn->fn_flags &= ~RTN_RTINFO;
		rt6_stats.fib_route_nodes--;
		fn = fib6_repair_tree(fn);
	}

But I am not completely convinced that all of these lines
of code can be removed :-)
