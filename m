From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] emac: Fix EMAC soft reset on 460EX/GT
Date: Sat, 11 May 2013 17:40:39 -0700 (PDT)
Message-ID: <20130511.174039.1747680568639795324.davem@davemloft.net>
References: <20130510025021.C97AF10045D@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088Ab3ELAkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 20:40:40 -0400
In-Reply-To: <20130510025021.C97AF10045D@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Thu, 9 May 2013 19:50:00 -0700

> Fix EMAC soft reset on 460EX/GT to select the right PHY clock source
> before and after the soft reset.
> 
> EMAC with PHY should use the clock from PHY during soft reset.
> EMAC without PHY should use the internal clock during soft reset.
> 
> PPC460EX/GT Embedded Processor Advanced User's Manual
> section 28.10.1 Mode Register 0 (EMACx_MR0) states:
> Note: The PHY must provide a TX Clk in order to perform a soft reset
> of the EMAC. If none is present, select the internal clock
> (SDR0_ETH_CFG[EMACx_PHY_CLK] = 1).
> After a soft reset, select the external clock.
> 
> Without the fix, 460EX/GT-based boards with RGMII PHYs attached to
> EMACs experience EMAC interrupt storm and system watchdog reset when
> issuing "ifconfig eth0 down" + "ifconfig eth0 up" a few times.
> The system enters endless loop of serving emac_irq() with EMACx_ISR
> register stuck at value 0x10000000 (Rx parity error).
> 
> With the fix, the above issue is no longer observed.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied.
