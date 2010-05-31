From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ixp4xx: Support the all multicast flag on the NPE
 devices.
Date: Mon, 31 May 2010 17:34:19 +0200
Message-ID: <20100531153419.GA17317@riccoc20.at.omicron.at>
References: <20100531131102.GA15870@riccoc20.at.omicron.at>
 <m3pr0c17ue.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:43822 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab0EaPds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 11:33:48 -0400
Received: by fg-out-1718.google.com with SMTP id l26so807672fgb.1
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 08:33:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <m3pr0c17ue.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 31, 2010 at 04:09:13PM +0200, Krzysztof Halasa wrote:
> Looks good, though I'd prefer a bit of "const" and "static" in the
> allmulti[] declaration. Would you please repost? TIA.

Okay, here it is.

Thanks,
Richard

This patch adds support for the IFF_ALLMULTI flag. Previously only the
IFF_PROMISC flag was supported.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/arm/ixp4xx_eth.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 6be8b09..42b4361 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -739,6 +739,17 @@ static void eth_set_mcast_list(struct net_device *dev)
 	struct dev_mc_list *mclist;
 	u8 diffs[ETH_ALEN], *addr;
 	int i;
+	static const u8 allmulti[] = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
+
+	if (dev->flags & IFF_ALLMULTI) {
+		for (i = 0; i < ETH_ALEN; i++) {
+			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
+			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);
+		}
+		__raw_writel(DEFAULT_RX_CNTRL0 | RX_CNTRL0_ADDR_FLTR_EN,
+			&port->regs->rx_control[0]);
+		return;
+	}
 
 	if ((dev->flags & IFF_PROMISC) || netdev_mc_empty(dev)) {
 		__raw_writel(DEFAULT_RX_CNTRL0 & ~RX_CNTRL0_ADDR_FLTR_EN,
-- 
1.6.3.3

