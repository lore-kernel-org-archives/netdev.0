From: c4p7n@capitanio.org
Subject: Re: [patch] rtl8102e: commit 7bf6bf480 zeroized MAC address
Date: Wed, 15 Oct 2008 15:57:35 +0200 (MEST)
Message-ID: <200810151357.m9FDvZqk028829@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, kernel@vger.kernel.org
To: "Ivan Vecera" <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from em-p00-ob.rzone.de ([81.169.146.225]:58981 "EHLO
	em-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbYJON5i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 09:57:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Ivan Vecera<ivecera@redhat.com>
> c4p7n@capitanio.org wrote:
> > Tested on top of linus tree and back ported 2.6.27.
> > 
> > Please cc me, thanks
> > Martin Capitanio
> > 
> I think this one is more common.

What about to mix both?
If the address is not stored here than it must be somewhere else --
or the read algorithm is broken ;-)

May be we are reading just by luck zeros and not a random perfectly sane address.
Personally I would prefer in this fine driver, just not doing what is not absolutely
needed. It would be great to figure out if all of the rtl8102e, etc. doesn't have this location. 

You can hardly desolder those chips from notebooks and I am really happy if this
_just works_ with as much realtek blessing as possible.

Martin

P.S. Apologize, I'm forced to use this * webmailer.
> 
> Ivan
> 
> =====
> Subject: [PATCH] [r8169] initialize MAC address found in EEPROM only if is
> it valid
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/r8169.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index c821da2..587a96c 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1975,8 +1975,9 @@ static void rtl_init_mac_address(struct
> rtl8169_private *tp,
>  
>  	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
>  
> -	/* Write MAC address */
> -	rtl_rar_set(tp, mac);
> +	/* Write MAC address if is it valid */
> +	if (is_valid_ether_addr(mac))
> +		rtl_rar_set(tp, mac);
>  }
>  
>  static int __devinit
> -- 
> 1.5.6.3
> 

--- original message end ----

