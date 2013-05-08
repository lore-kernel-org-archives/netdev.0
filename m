From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Wed, 08 May 2013 13:15:35 -0700 (PDT)
Message-ID: <20130508.131535.1684695560935318559.davem@davemloft.net>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, r.schwebel@pengutronix.de,
	l.stach@pengutronix.de, netdev@vger.kernel.org, festevam@gmail.com,
	shawn.guo@linaro.org, lznuaa@gmail.com
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755472Ab3EHUPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:15:36 -0400
In-Reply-To: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Wed, 8 May 2013 08:08:44 +0800

> reproduce steps
>  1. flood ping from other machine
>  	ping -f -s 41000 IP
>  2. run below script
>     while [ 1 ]; do ethtool -s eth0 autoneg off;
>     sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;
> 
> You can see oops in one hour.
> 
> The reason is fec_restart clear BD but NAPI may use it.
> The solution is disable NAPI and stop xmit when reset BD.
> disable NAPI may sleep, so fec_restart can't be call in
> atomic context.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
> Tested-by: Lucas Stach <l.stach@pengutronix.de>

Applied and queued up for -stable.
