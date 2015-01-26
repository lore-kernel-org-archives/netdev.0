From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bonding: handle more gso types
Date: Sun, 25 Jan 2015 23:34:57 -0800 (PST)
Message-ID: <20150125.233457.670732490091749052.davem@davemloft.net>
References: <1422021446.29618.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422257234.29618.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbbAZHe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 02:34:58 -0500
In-Reply-To: <1422257234.29618.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 25 Jan 2015 23:27:14 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 5a7baa78851b ("bonding: Advertize vxlan offload features when
> supported"), Or Gerlitz added support conditional vxlan offload.
> 
> In this patch I also add support for all kind of tunnels,
> but we allow a bonding device to not require segmentation,
> as it is always better to make this segmentation at the very last stage,
> if a particular slave device requires it.
> 
> Tested:
> 
>  Setup a GRE tunnel,
>  on a physical NIC not having tx-gre-segmentation.
>  Results on bnx2x are even better, as we no longer have to segment
>  in software.
> 
> ethtool -K bond0 tx-gre-segmentation off
> 
> super_netperf 50 --google-pacing-rate 30000000 -H 10.7.8.152 -l 15
> 7538.32
> 
> ethtool -K bond0 tx-gre-segmentation on 
> 
> super_netperf 50 --google-pacing-rate 30000000 -H 10.7.8.152 -l 15
> 10200.5
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
