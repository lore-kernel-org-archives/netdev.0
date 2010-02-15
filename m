From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] niu.c: Use pr_<level>, netdev_<level> and
 netif_<level> macros
Date: Mon, 15 Feb 2010 00:23:19 -0800
Message-ID: <1266222199.16721.967.camel@Joe-Laptop.home>
References: <20100212.123129.163263355.davem@davemloft.net>
	 <1266194829.16721.940.camel@Joe-Laptop.home>
	 <20100214.224108.51485961.davem@davemloft.net>
	 <20100215.001319.150697350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1046 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab0BOIXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 03:23:20 -0500
In-Reply-To: <20100215.001319.150697350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-15 at 00:13 -0800, David Miller wrote:
> I just added the following refinements on top of your
> changes to net-next-2.6
[]
> drivers/net/niu.c |   26 +-------------------------
>  1 files changed, 1 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> index 347788f..5e604e3 100644
> --- a/drivers/net/niu.c
> +++ b/drivers/net/niu.c
[]
> @@ -4246,13 +4241,11 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
>  	v2 = nr64(LDSV2(ldg));
>  
>  	if (netif_msg_intr(np))
> -		pr_cont(" v0[%llx] v1[%llx] v2[%llx]",
> +		pr_cont(" v0[%llx] v1[%llx] v2[%llx]\n",
>  		       (unsigned long long) v0,
>  		       (unsigned long long) v1,
>  		       (unsigned long long) v2);
>  
> -	pr_cont("\n");
> -
>  	if (unlikely(!v0 && !v1 && !v2)) {
>  		spin_unlock_irqrestore(&np->lock, flags);
>  		return IRQ_NONE;
 
This creates a logging message without trailing \n
if netif_msg_intr is false.


