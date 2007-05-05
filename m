From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 9/11][TG3]: Add ASPM workaround.
Date: Fri, 04 May 2007 20:40:09 -0400
Message-ID: <463BD269.7010501@garzik.org>
References: <1178326514.4859.25.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53252 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423707AbXEEAkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:40:12 -0400
In-Reply-To: <1178326514.4859.25.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -3019,6 +3019,15 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
>  		}
>  	}
>  
> +	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND) {
> +		u32 val = tr32(0x7d28);
> +		if (!netif_carrier_ok(tp->dev))
> +			val = (val & ~0x0000ff00) | tp->pwrmgmt_thresh;
> +		else
> +			val |= 0x0000ff00;
> +		tw32(0x7d28, val);
> +	}
> +
>  	return err;
>  }
>  
> @@ -10997,6 +11016,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
>  	 */
>  	tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
>  
> +	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND)
> +		tp->pwrmgmt_thresh = tr32(0x7d28) & 0x0000ff00;


NAK -- magic numbers.

Please create a named constant for the register at 0x7d28.

	Jeff


