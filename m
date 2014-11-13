From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] smsc911x: power-up phydev before doing a software
 reset.
Date: Thu, 13 Nov 2014 15:09:56 -0500 (EST)
Message-ID: <20141113.150956.1894676742782542194.davem@davemloft.net>
References: <1415866474-11626-1-git-send-email-eballetbo@iseebcn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	javier@dowhile0.org, ebutera@gmail.com
To: eballetbo@iseebcn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933383AbaKMUJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 15:09:59 -0500
In-Reply-To: <1415866474-11626-1-git-send-email-eballetbo@iseebcn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Enric Balletbo i Serra <eballetbo@iseebcn.com>
Date: Thu, 13 Nov 2014 09:14:34 +0100

> With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
> to HALTED"), the PHY device will be put in a low-power mode using
> BMCR_PDOWN if the the interface is set down. The smsc911x driver does
> a software_reset opening the device driver (ndo_open). In such case,
> the PHY must be powered-up before access to any register and before
> calling the software_reset function. Otherwise, as the PHY is powered
> down the software reset fails and the interface can not be enabled
> again.
> 
> This patch fixes this scenario that is easy to reproduce setting down
> the network interface and setting up again.
> 
>     $ ifconfig eth0 down
>     $ ifconfig eth0 up
>     ifconfig: SIOCSIFFLAGS: Input/output error
> 
> Signed-off-by: Enric Balletbo i Serra <eballetbo@iseebcn.com>

Applied and queued up for -stable, thanks.
