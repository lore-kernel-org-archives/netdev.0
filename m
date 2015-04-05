From: David Miller <davem@davemloft.net>
Subject: Re: 3.19+: (and quite probably earlier) VIA Rhine hanging under
 high network load, yet again: redux
Date: Sun, 05 Apr 2015 00:01:34 -0400 (EDT)
Message-ID: <20150405.000134.2167854544742576874.davem@davemloft.net>
References: <874mov7otu.fsf@spindle.srvr.nix>
	<20150404210518.GA7698@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nix@esperi.org.uk, rl@hellgate.ch, gurligebis@gentoo.org,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbbDEEBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2015 00:01:43 -0400
In-Reply-To: <20150404210518.GA7698@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 4 Apr 2015 23:05:18 +0200

> Nix <nix@esperi.org.uk> :
> [...]
> 
> This driver leaves holes in its receive ring under memory pressure.
> It may not help.
> 
> You can try the gross patch below against v3.19. It compiles. I have to go.

Indeed, converting this driver to just drop packets when skb
allocation fails on receive, and just reusing the original skb and
placing it back into the RX ring, is the way to go.
