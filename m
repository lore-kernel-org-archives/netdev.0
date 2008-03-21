From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Fri, 21 Mar 2008 20:20:34 +0800
Message-ID: <989B956029373F45A0B8AF029708189001D19565@zch01exm26.fsl.freescale.net>
References: <> <1205853088-30171-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Joakim Tjernlund" <Joakim.Tjernlund@transmode.se>,
	"Netdev" <netdev@vger.kernel.org>,
	"Linuxppc-Embedded@Ozlabs.Org" <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:33071 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbYCUMUl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 08:20:41 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m2LCKadi025540
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 05:20:37 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m2LCKZ2r011048
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 07:20:35 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1205853088-30171-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Joakim Tjernlund
> Sent: Tuesday, March 18, 2008 11:11 PM
> To: Netdev; Li Yang
> Cc: Joakim Tjernlund
> Subject: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
> 
> Creating a VLAN interface on top of ucc_geth adds 4 bytes to 
> the frame and the HW controller is not prepared to TX a frame 
> bigger than 1518 bytes which is 4 bytes too small for a full 
> VLAN frame. Also add 4 extra bytes for future expansion.

IMO, VLAN and Jumbo packet support is not general case of Ethernet.
Could you make this change optional?  Thanks.

- Leo

> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ucc_geth.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c 
> index 348892b..038ec75 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -114,10 +114,10 @@ static struct ucc_geth_info 
> ugeth_primary_info = {
>  	.maxGroupAddrInHash = 4,
>  	.maxIndAddrInHash = 4,
>  	.prel = 7,
> -	.maxFrameLength = 1518,
> +	.maxFrameLength = 1518+8, /* Add 4 bytes for VLAN tags 
> and 4 extra 
> +bytes */
>  	.minFrameLength = 64,
> -	.maxD1Length = 1520,
> -	.maxD2Length = 1520,
> +	.maxD1Length = 1520+8,
> +	.maxD2Length = 1520+8,
>  	.vlantype = 0x8100,
>  	.ecamptr = ((uint32_t) NULL),
>  	.eventRegMask = UCCE_OTHER,
> --
> 1.5.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe 
> netdev" in the body of a message to majordomo@vger.kernel.org 
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
