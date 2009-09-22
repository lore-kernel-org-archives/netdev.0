From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Set SKY2_HW_RAM_BUFFER in sky2_init
Date: Mon, 21 Sep 2009 19:50:41 -0700
Message-ID: <20090921195041.14a22788@nehalam>
References: <4AB788F4.90503@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54134 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751629AbZIVCvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 22:51:25 -0400
In-Reply-To: <4AB788F4.90503@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Sep 2009 23:08:52 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> The SKY2_HW_RAM_BUFFER bit in hw->flags was checked in sky2_mac_init(),
>  before being set later in sky2_up().
> 
> Setting SKY2_HW_RAM_BUFFER in sky2_init() where other hw->flags are set
>  should avoid this problem recurring.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/sky2.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 4bb52e9..68d256b 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1497,7 +1497,6 @@ static int sky2_up(struct net_device *dev)
>  	if (ramsize > 0) {
>  		u32 rxspace;
>  
> -		hw->flags |= SKY2_HW_RAM_BUFFER;
>  		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
>  		if (ramsize < 16)
>  			rxspace = ramsize / 2;
> @@ -2926,6 +2925,9 @@ static int __devinit sky2_init(struct sky2_hw *hw)
>  			++hw->ports;
>  	}
>  
> +	if (sky2_read8(hw, B2_E_0))
> +		hw->flags |= SKY2_HW_RAM_BUFFER;
> +
>  	return 0;
>  }
>  

This should go to stable tree as well.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
