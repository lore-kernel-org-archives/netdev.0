From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: some rt_iif -> rt_route_iif conversions
Date: Thu, 11 Aug 2011 06:01:10 -0700 (PDT)
Message-ID: <20110811.060110.955532382602835203.davem@davemloft.net>
References: <alpine.LFD.2.00.1108091651290.1527@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab1HKNBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 09:01:21 -0400
In-Reply-To: <alpine.LFD.2.00.1108091651290.1527@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 9 Aug 2011 17:01:16 +0300 (EEST)

> 
> 	As rt_iif represents input device even for packets
> coming from loopback with output route, it is not an unique
> key specific to input routes. Now rt_route_iif has such role,
> it was fl.iif in 2.6.38, so better to change the checks at
> some places to save CPU cycles and to restore 2.6.38 semantics.
> 
> compare_keys:
> 	- input routes: only rt_route_iif matters, rt_iif is same
> 	- output routes: only rt_oif matters, rt_iif is not
> 		used for matching in __ip_route_output_key
> 	- now we are back to 2.6.38 state
> 
> ip_route_input_common:
> 	- matching rt_route_iif implies input route
> 	- compared to 2.6.38 we eliminated one rth->fl.oif check
> 	because it was not needed even for 2.6.38
> 
> compare_hash_inputs:
> 	Only the change here is not an optimization, it has
> 	effect only for output routes. I assume I'm restoring
> 	the original intention to ignore oif, it was using fl.iif
> 	- now we are back to 2.6.38 state
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks a lot for doing these audits.
