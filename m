From: Mike Phillips <mikep@linuxtr.net>
Subject: Re: [2.6 patch] olympic_open() must be __devinit
Date: Mon, 11 Feb 2008 14:03:35 -0500
Message-ID: <20080211190335.GA4304@linuxtr.net>
References: <20080130200207.GJ29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: p2@ace.ulyssis.student.kuleuven.ac.be, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phl-30-a-50.phl.dsl.cerfnet.com ([63.242.148.50]:4261 "EHLO
	ns1.linuxtr.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbYBKSqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 13:46:47 -0500
Content-Disposition: inline
In-Reply-To: <20080130200207.GJ29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 10:02:07PM +0200, Adrian Bunk wrote:
> This patch fixes the following section mismatch:
> 
> <--  snip  -->
> 
> ...
> WARNING: drivers/net/built-in.o(.text+0x155573): Section mismatch in reference from the function olympic_open() to the function .devinit.text:olympic_init()
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> fd1e6e0bb5b17dc85cd24d6263e8751e816f59e6 
> diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
> index e7b4adc..433c994 100644
> --- a/drivers/net/tokenring/olympic.c
> +++ b/drivers/net/tokenring/olympic.c
> @@ -434,7 +434,7 @@ static int __devinit olympic_init(struct net_device *dev)
>  
>  }
>  
> -static int olympic_open(struct net_device *dev) 
> +static int __devinit olympic_open(struct net_device *dev) 
>  {
>  	struct olympic_private *olympic_priv=netdev_priv(dev);
>  	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio,*init_srb;
> 
> 

If __devinit marked code is still discarded after initial setup then NACK. open can be called at any time the 
interface is ifup'ed. Its most definitely not adapter init code (that's all done in probe).  

Mike

