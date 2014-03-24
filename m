From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: optimize csum_replace2()
Date: Mon, 24 Mar 2014 00:20:59 -0400 (EDT)
Message-ID: <20140324.002059.1347431123598236103.davem@davemloft.net>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140321.140730.1007660405690890605.davem@davemloft.net>
	<1395629496.9117.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hkchu@google.com, mwdalton@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbaCXEVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 00:21:03 -0400
In-Reply-To: <1395629496.9117.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 23 Mar 2014 19:51:36 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When changing one 16bit value by another in IP header, we can adjust the
> IP checksum by doing a simple operation described in RFC 1624,
> as reminded by David.
> 
> csum_partial() is a complex function on x86_64, not really suited
> for small number of checksummed bytes.
> 
> I spotted csum_partial() being in the top 20 most consuming
> functions (more than 1 %) in a GRO workload, which was rather
> unexpected.
> 
> The caller was inet_gro_complete() doing a csum_replace2() when
> building the new IP header for the GRO packet.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks for following through on this Eric.

Would be nice to improve csum_replace4() similarly, since every
NAT packet uses that thing when we change the address in the
protocol header.
