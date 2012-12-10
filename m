From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] inet_diag: avoid unsafe and nonsensical prefix
 matches in inet_diag_bc_run()
Date: Sun, 09 Dec 2012 19:01:44 -0500 (EST)
Message-ID: <20121209.190144.1678804883083950693.davem@davemloft.net>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
	<1355031803-14547-3-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999Ab2LJABq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 19:01:46 -0500
In-Reply-To: <1355031803-14547-3-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun,  9 Dec 2012 00:43:23 -0500

> Add logic to check the address family of the user-supplied conditional
> and the address family of the connection entry. We now do not do
> prefix matching of addresses from different address families (AF_INET
> vs AF_INET6), except for the previously existing support for having an
> IPv4 prefix match an IPv4-mapped IPv6 address (which this commit
> maintains as-is).
> 
> This change is needed for two reasons:
> 
> (1) The addresses are different lengths, so comparing a 128-bit IPv6
> prefix match condition to a 32-bit IPv4 connection address can cause
> us to unwittingly walk off the end of the IPv4 address and read
> garbage or oops.
> 
> (2) The IPv4 and IPv6 address spaces are semantically distinct, so a
> simple bit-wise comparison of the prefixes is not meaningful, and
> would lead to bogus results (except for the IPv4-mapped IPv6 case,
> which this commit maintains).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
