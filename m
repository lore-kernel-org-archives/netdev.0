From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix compile error when IPV6=m and TIPC=y
Date: Tue, 24 Mar 2015 15:21:03 -0400 (EDT)
Message-ID: <20150324.152103.1882579305066252346.davem@davemloft.net>
References: <1427187561-25064-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbCXTVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:21:06 -0400
In-Reply-To: <1427187561-25064-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 24 Mar 2015 16:59:21 +0800

> When IPV6=m and TIPC=y, below error will appear during building kernel
> image:
> 
> net/tipc/udp_media.c:196:
> undefined reference to `ip6_dst_lookup'
> make: *** [vmlinux] Error 1
> 
> As ip6_dst_lookup() is implemented in IPV6 and IPV6 is compiled as
> module, ip6_dst_lookup() is not built-in core kernel image. As a
> result, compiler cannot find 'ip6_dst_lookup' reference while
> compiling TIPC code into core kernel image.
> 
> But with the method introduced by commit 5f81bd2e5d80 ("ipv6: export a
> stub for IPv6 symbols used by vxlan"), we can avoid the compile error
> through "ipv6_stub" pointer to access ip6_dst_lookup().
> 
> Fixes: d0f91938bede ("tipc: add ip/udp media type")
> Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied.
