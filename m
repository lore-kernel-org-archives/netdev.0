From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Sun, 02 Nov 2008 08:18:45 -0500
Message-ID: <490DA8B5.2020303@garzik.org>
References: <1221524685-25968-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60450 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753472AbYKBNSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 08:18:49 -0500
In-Reply-To: <1221524685-25968-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> Creating a VLAN interface on top of ucc_geth adds 4 bytes
> to the frame and the HW controller is not prepared to
> TX a frame bigger than 1518 bytes which is 4 bytes too
> small for a full VLAN frame. Also add 4 extra bytes for future
> expansion.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ucc_geth.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 8f944e5..8fed4bb 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -113,10 +113,10 @@ static struct ucc_geth_info ugeth_primary_info = {
>  	.maxGroupAddrInHash = 4,
>  	.maxIndAddrInHash = 4,
>  	.prel = 7,
> -	.maxFrameLength = 1518,
> +	.maxFrameLength = 1518+8, /* Add 4 bytes for VLAN tags and 4 extra bytes */
>  	.minFrameLength = 64,
> -	.maxD1Length = 1520,
> -	.maxD2Length = 1520,
> +	.maxD1Length = 1520+8,
> +	.maxD2Length = 1520+8,
>  	.vlantype = 0x8100,

Is this still needed?

I found this buried in my inbox.

If so, please resend with the "+8" converted into a named constant. 
Hardcoding lengths like this without named constants (or comments, on 
the other lines) tends to be an error-prone practice.

	Jeff



