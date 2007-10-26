From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1] net: fix and typo's
Date: Fri, 26 Oct 2007 10:51:46 -0700
Message-ID: <47222932.80408@intel.com>
References: <47221EBE.3070109@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: Roel Kluin <12o3l@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33566 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757495AbXJZRwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 13:52:06 -0400
In-Reply-To: <47221EBE.3070109@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roel Kluin wrote:
> A few patches with changes to net code. I have sent these to the lkml
> previously, but they were not yet merged. I am fairly new to kernel 
> programming, so it is possible that I make some mistakes. I'll explain my
> rationale, please nack if incorrect, an additional bit of explanation is
> appreciated even more.
> 
> The condition '!x & y,' does make little sense: the '!' has a higher
> priority than '&'. It behaves therefore like '!x && y'. In the case 
> bitanding flags, however, '!(x & y)' appears to be desired.
> 
> Warning: the change of '!x & y,' to '!(x & y)' may change behavior. if
> not desired, I propose changing this to '!x && y', to make it explicitly
> clear.
> 
> These '&' typo's can be spotted with:
> a="A-Za-z0-9_"
> git-grep "\![^$a()]*[$a]\+\([$a.]*\|->\)*\(\[[$a.]*\]\)\?[ \W]*&[^&]\+"
> 
> --
>         Fix priority mistakes similar to '!x & y'
>     
>         Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
> index cf70522..14141a5 100644
> --- a/drivers/net/e1000e/82571.c
> +++ b/drivers/net/e1000e/82571.c
> @@ -283,7 +283,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
>  			adapter->flags &= ~FLAG_HAS_WOL;
>  		/* quad ports only support WoL on port A */
>  		if (adapter->flags & FLAG_IS_QUAD_PORT &&
> -		    (!adapter->flags & FLAG_IS_QUAD_PORT_A))
> +		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
>  			adapter->flags &= ~FLAG_HAS_WOL;
>  		break;
>  



Ack this e1000e change here!


Auke


(PS since there was only 1 netdriver patch here and the rest is wireless, I would
have suggested splitting this patch up in two and sending them to the wireless
maintainer and netdevice maintainer separately. But I'm sure this will get picked
up anyway.)
