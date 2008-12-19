From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH -next] ppp: fix segfaults introduced by netdev_priv changes
Date: Fri, 19 Dec 2008 08:42:01 +0800
Message-ID: <494AEDD9.9060802@cn.fujitsu.com>
References: <200812181838.mBIIcLlw019317@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55416 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbYLSAmO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 19:42:14 -0500
In-Reply-To: <200812181838.mBIIcLlw019317@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman said the following on 2008-12-19 2:38:
> This patch fixes a segfault in ppp_shutdown_interface() and
> ppp_destroy_interface() when a PPP connection is closed. I bisected
> the problem to the following commit:
> 
>   commit c8019bf3aff653cceb64f66489fc299ee5957b57
>   Author: Wang Chen <wangchen@cn.fujitsu.com>
>   Date:   Thu Nov 20 04:24:17 2008 -0800
> 
>     netdevice ppp: Convert directly reference of netdev->priv
>     
>     1. Use netdev_priv(dev) to replace dev->priv.
>     2. Alloc netdev's private data by alloc_netdev().
>     
>     Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> The original ppp_generic code treated the netdev and struct ppp as
> independent data structures which were freed separately. In moving the
> ppp struct into the netdev, it is now possible for the private data to
> be freed before the call to ppp_shutdown_interface(), which is bad.
> 
> The kfree(ppp) in ppp_destroy_interface() is also wrong; presumably
> ppp hasn't worked since the above commit.
> 
> The following patch fixes both problems.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> 

It's ok to me.
Reviewed-by: Wang Chen <wangchen@cn.fujitsu.com>

