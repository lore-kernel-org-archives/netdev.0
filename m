From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix headroom calculation in udp6_ufo_fragment
Date: Tue, 05 Nov 2013 22:10:25 -0500 (EST)
Message-ID: <20131105.221025.1890710578395202777.davem@davemloft.net>
References: <4BC5337E23A5EE4A96D91D9DABA8FAE55E440B568D@WP40068.corp.ads>
	<20131103033207.GF30284@order.stressinduktion.org>
	<20131105014127.GG8832@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Saran.Neti@telus.com, netdev@vger.kernel.org, pshelar@nicira.com,
	tsl-vulnerability-research@telus.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174Ab3KFDK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 22:10:28 -0500
In-Reply-To: <20131105014127.GG8832@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 5 Nov 2013 02:41:27 +0100

> Commit 1e2bd517c108816220f262d7954b697af03b5f9c ("udp6: Fix udp
> fragmentation for tunnel traffic.") changed the calculation if
> there is enough space to include a fragment header in the skb from a
> skb->mac_header dervived one to skb_headroom. Because we already peeled
> off the skb to transport_header this is wrong. Change this back to check
> if we have enough room before the mac_header.
> 
> This fixes a panic Saran Neti reported. He used the tbf scheduler which
> skb_gso_segments the skb. The offsets get negative and we panic in memcpy
> because the skb was erroneously not expanded at the head.
> 
> Reported-by: Saran Neti <Saran.Neti@telus.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks Hannes.
