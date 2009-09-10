From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2 3/3] ucc_geth: Fix hangs after switching from full
 to	half duplex
Date: Thu, 10 Sep 2009 13:04:32 -0500
Message-ID: <4AA93FB0.5060802@freescale.com>
References: <20090910020145.GC31083@oksana.dev.rtsoft.ru> <20090910175852.GA18948@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	Timur Tabi <timur@freescale.com>, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57407 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbZIJSEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 14:04:04 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n8AI45tV012892
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 11:04:06 -0700 (MST)
Received: from az33exm25.fsl.freescale.net (az33exm25.am.freescale.net [10.64.32.16])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n8AI5lKQ003580
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 13:05:47 -0500 (CDT)
In-Reply-To: <20090910175852.GA18948@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> MPC8360 QE UCC ethernet controllers hang when changing link duplex
> under a load (a bit of NFS activity is enough).
> 
>   PHY: mdio@e0102120:00 - Link is Up - 1000/Full
>   sh-3.00# ethtool -s eth0 speed 100 duplex half autoneg off
>   PHY: mdio@e0102120:00 - Link is Down
>   PHY: mdio@e0102120:00 - Link is Up - 100/Half
>   NETDEV WATCHDOG: eth0 (ucc_geth): transmit queue 0 timed out
>   ------------[ cut here ]------------
>   Badness at c01fcbd0 [verbose debug info unavailable]
>   NIP: c01fcbd0 LR: c01fcbd0 CTR: c0194e44
>   ...
> 
> The cure is to disable the controller before changing speed/duplex
> and enable it afterwards.
> 
> Since ugeth_graceful_stop_{tx,rx} now may be called from an atomic
> context, switch the two functions from msleep() to mdelay().

Ouch.  Can we put this in a workqueue or something?

-Scott
