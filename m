From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Misuse of LRO, how widespread
Date: Mon, 06 Dec 2010 23:22:35 +0000
Message-ID: <1291677755.5405.29.camel@bwh-desktop>
References: <20101206121829.5b8c852e@nehalam>	<4CFD527E.7000706@chelsio.com>
	 <20101206142715.0d296b25@nehalam>  <4CFD6C2B.9020201@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31340 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216Ab0LFXWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 18:22:41 -0500
In-Reply-To: <4CFD6C2B.9020201@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-06 at 15:05 -0800, Dimitris Michailidis wrote:
> Stephen Hemminger wrote:
> > On Mon, 06 Dec 2010 13:15:42 -0800
> > Dimitris Michailidis <dm@chelsio.com> wrote:
> > 
> >> Stephen Hemminger wrote:
> >>> I inspected all drivers in net-next to see which drivers are using
> >>> LRO and which ones are broken. Most concerning is that Chelsio
> >>> and Solarflare drivers ignore ETH_FLAG_LRO.
> >>>
> >>> The ones that are using LRO but allow disabling it:
> >>>   qlcnic, netxen, mv643, s2io, myi10ge, bnx2x, ixgbe, vmxnet3
> >>>
> >>> One driver seems confused about LRO vs GRO:
> >>>   mlx4 - comments about LRO and depends on LRO but driver is using GRO
> >>>
> >>> Drivers with not using ethtool interface to disable LRO:
> >>>   pasemi_mac, sfc, ehea, cxgb3, cxgb4
> >> cxgb4 uses GRO, not LRO.
> > 
> > Ok. but cxgb3 still uses LRO (or it least calls it lro).
> > 
> 
> cxgb3 was the driver Herbert implemented GRO on I think, and he converted it 
> to GRO.  It possibly has leftover LRO references as it was using LRO before.

There's a fair amount of code setting LRO flags in various structures,
so either the driver still enables LRO in hardware/firmware or this is
dead code.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

