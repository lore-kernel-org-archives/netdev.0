From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: [PATCH 1/2] bnx2x:Fix error handling for the function
 bnx2x_set_mutl_gpio
Date: Mon, 7 Mar 2016 14:50:36 +0000
Message-ID: <CY1PR11MB0828B458879F2A5F638491B38AB10@CY1PR11MB0828.namprd11.prod.outlook.com>
References: <1457316274-18951-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0113.outbound.protection.outlook.com ([157.56.110.113]:56768
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752350AbcCGOuj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 09:50:39 -0500
In-Reply-To: <1457316274-18951-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nicholas Krause [mailto:xerofoify@gmail.com]
> Sent: Monday, March 07, 2016 4:05 AM
> To: Ariel Elior <Ariel.Elior@qlogic.com>
> Cc: netdev <netdev@vger.kernel.org>; linux-kernel <linux-kernel@vger.kernel.org>
> Subject: [PATCH 1/2] bnx2x:Fix error handling for the function bnx2x_set_mutl_gpio
> 
> This fixes the error handling for the function bnx2x_set_mutl_gpio
> for checking if the function bnx2x_acquire_hw_lock ran successfully
> by not returning a error code and if it does return the error code
> to this function's caller in addition to exiting from this function
> immediately due to this failure.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index c27af12..a55f1c2 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2151,7 +2151,9 @@ int bnx2x_set_mult_gpio(struct bnx2x *bp, u8 pins, u32
> mode)
> 
>  	/* Any port swapping should be handled by caller. */
> 
> -	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
> +	rc = bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
> +	if (rc)
> +		return rc;
>  	/* read GPIO and mask except the float bits */
>  	gpio_reg = REG_RD(bp, MISC_REG_GPIO);
>  	gpio_reg &= ~(pins << MISC_REGISTERS_GPIO_FLOAT_POS);
> --
> 2.1.4
Thanks Nicholas.
Acked-by: Ariel Elior <ariel.elior@qlogic.com>
