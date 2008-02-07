From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: low power mode
Date: Thu, 07 Feb 2008 12:21:01 +0100
Message-ID: <47AAE99D.1000908@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47A9EA42.3080800@eptar.com> <200802062208.17435.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay04.albacom.net ([217.220.57.147]:6313 "EHLO
	fe-relay04.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbYBGLTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 06:19:54 -0500
In-Reply-To: <200802062208.17435.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry,
let me repeat what I said in previous mail.
I propose you to add set_lowpower(true) in the enc28j60_probe() and in 
the enc28j60_net_close() after enc28j60_hw_disable().
Probably we don't need to set_lowpower(false) in enc28j60_net_open() since
it performs a soft reset with enc28j60_hw_init() (not sure).

Furthermore, as you suggested, we also need to remove hw_init() from the 
setlink()
because hw_init() is called when we bring link up.

--- enc28j60.c 20 Dec 2007 10:47:01 -0000 1.22
+++ enc28j60.c 7 Feb 2008 11:07:20 -0000
@@ -740,12 +740,6 @@
if (!priv->hw_enable) {
if (autoneg == AUTONEG_DISABLE && speed == SPEED_10) {
priv->full_duplex = (duplex == DUPLEX_FULL);
- if (!enc28j60_hw_init(priv)) {
- if (netif_msg_drv(priv))
- dev_err(&ndev->dev,
- "hw_reset() failed\n");
- ret = -EINVAL;
- }
} else {
if (netif_msg_link(priv))
dev_warn(&ndev->dev,

Can you update your low power patch with these modifications?

