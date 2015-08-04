From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Mon, 03 Aug 2015 22:23:58 -0700 (PDT)
Message-ID: <20150803.222358.372324734978710162.davem@davemloft.net>
References: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	patchwork-lst@pengutronix.de
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001AbbHDFX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:23:59 -0400
In-Reply-To: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Mon,  3 Aug 2015 17:50:11 +0200

> The clocks are initially active and thus the device is marked active.
> This still keeps the PM refcount at 0, the pm_runtime_put_autosuspend()
> call at the end of probe then leaves us with an invalid refcount of -1,
> which in turn leads to the device staying in suspended state even though
> netdev open had been called.
> 
> Fix this by initializing the refcount to be coherent with the initial
> device status.
> 
> Fixes:
> 8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio bus)
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
> Please apply this as a fix for 4.2

I'm waiting for feedback to be given wrt. the runtime-pm issues.
