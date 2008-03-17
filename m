From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: NEWEMAC: Support for Pause packets in EMAC driver
Date: Mon, 17 Mar 2008 08:08:35 -0400
Message-ID: <47DE5F43.80604@garzik.org>
References: <1205488348-22536-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	benh@kernel.crashing.org, jwboyer@linux.vnet.ibm.com
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42315 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbYCQMIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:08:39 -0400
In-Reply-To: <1205488348-22536-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Roese wrote:
> From: Pravin M. Bathija <pbathija@amcc.com>
> 
> Problem Description and Fix
> ---------------------------
> When a pause packet(with destination as reserved Multicast address) is
> received by the EMAC hardware to control the flow of frames being
> transmitted by it, it is dropped by the hardware unless the reserved
> Multicast address is hashed in to the GAHT[1-4] registers. This code fix
> adds the default reserved multicast address to the GAHT[1-4] registers
> in the EMAC(s) present on the chip. The flow control with Pause packets
> will only work if the following register bits are programmed in EMAC:
> EMACx_MR1[APP] = 1
> EMACx_RMR[BAE] = 1
> EMACx_RMR[MAE] = 1
> 
> Behavior that may be observed in a running system
> -------------------------------------------------
> A host transferring data from a PPC based system may send a Pause packet
> to the PPC EMAC requesting it to slow down the flow of packets. If the
> default reserved multicast MAC address is not programmed into the
> GAHT[1-4] registers this Pause packet will be dropped by PPC EMAC and no
> Flow Control will be done.
> 
> Signed-off-by: Pravin M. Bathija <pbathija@amcc.com>
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/core.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)

applied


