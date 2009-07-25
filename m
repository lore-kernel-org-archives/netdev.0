From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] fealnx: Write outside array bounds
Date: Sat, 25 Jul 2009 12:55:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0907251253350.26274@melkinkari.cs.Helsinki.FI>
References: <4A699FC2.2080407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60938 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbZGYJzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 05:55:19 -0400
In-Reply-To: <4A699FC2.2080407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Jul 2009, Roel Kluin wrote:

> phy_idx is checked to be < 4, but np->phys[] is 2 elements long
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Or should the number of elements be increased?
> 
> diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
> index 48385c4..100badd 100644
> --- a/drivers/net/fealnx.c
> +++ b/drivers/net/fealnx.c
> @@ -584,7 +584,7 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
>  	if (np->flags == HAS_MII_XCVR) {
>  		int phy, phy_idx = 0;
>  
> -		for (phy = 1; phy < 32 && phy_idx < 4; phy++) {
> +		for (phy = 1; phy < 32 && phy_idx < 2; phy++) {
>  			int mii_status = mdio_read(dev, phy, 1);
>  
>  			if (mii_status != 0xffff && mii_status != 0x0000) {

In either of the case, one should use ARRAY_SIZE(np->phys) instead of the 
number.


-- 
 i.
