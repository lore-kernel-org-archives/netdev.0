From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] mv643xx_eth: move mac_addr inside of
 mv643xx_eth_platform_data
Date: Wed, 28 Feb 2007 15:11:03 -0800
Message-ID: <20070228151103.0c5a320d@freekitty>
References: <20070228224031.GA8233@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-mips@linux-mips.org,
	Ralf Baechle <ralf@linux-mips.org>
To: "Dale Farnsworth" <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:47274 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbXB1XRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 18:17:40 -0500
In-Reply-To: <20070228224031.GA8233@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Feb 2007 15:40:31 -0700
"Dale Farnsworth" <dale@farnsworth.org> wrote:

> The information contained within platform_data should be self-contained.
> Replace the pointer to a MAC address with the actual MAC address in
> struct mv643xx_eth_platform_data.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> 
> Index: b/drivers/net/mv643xx_eth.c
> ===================================================================
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -1380,7 +1380,9 @@ static int mv643xx_eth_probe(struct plat
>  
>  	pd = pdev->dev.platform_data;
>  	if (pd) {
> -		if (pd->mac_addr)
> +		static u8 zero_mac_addr[6] = { 0 };
> +
> +		if (memcmp(pd->mac_addr, zero_mac_addr, 6) != 0)
>  			memcpy(dev->dev_addr, pd->mac_addr, 6);


is_zero_ether_addr() is faster/cleaner for this

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
