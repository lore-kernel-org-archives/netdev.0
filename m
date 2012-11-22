From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: do not cache looped multicasts
Date: Thu, 22 Nov 2012 16:08:21 -0500 (EST)
Message-ID: <20121122.160821.1053003508424182997.davem@davemloft.net>
References: <1353618254-1874-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbizon@freebox.fr
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756022Ab2KVVI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:08:27 -0500
In-Reply-To: <1353618254-1874-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 22 Nov 2012 23:04:14 +0200

> 	Starting from 3.6 we cache output routes for
> multicasts only when using route to 224/4. For local receivers
> we can set RTCF_LOCAL flag depending on the membership but
> in such case we use maddr and saddr which are not caching
> keys as before. Additionally, we can not use same place to
> cache routes that differ in RTCF_LOCAL flag value.
> 
> 	Fix it by caching only RTCF_MULTICAST entries
> without RTCF_LOCAL (send-only, no loopback). As a side effect,
> we avoid unneeded lookup for fnhe when not caching because
> multicasts are not redirected and they do not learn PMTU.
> 
> 	Thanks to Maxime Bizon for showing the caching
> problems in __mkroute_output for 3.6 kernels: different
> RTCF_LOCAL flag in cache can lead to wrong ip_mc_output or
> ip_output call and the visible problem is that traffic can
> not reach local receivers via loopback.
> 
> Reported-by: Maxime Bizon <mbizon@freebox.fr>
> Tested-by: Maxime Bizon <mbizon@freebox.fr>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and queued up for -stable, thanks!
