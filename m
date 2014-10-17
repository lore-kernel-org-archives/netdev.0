From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] staging: octeon: Replace memcpy with ETH_ALEN
Date: Fri, 17 Oct 2014 12:40:48 -0700
Message-ID: <1413574848.14629.6.camel@perches.com>
References: <20141017184705.GA17944@vasu-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Balavasu <kp.balavasu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141017184705.GA17944@vasu-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-10-18 at 00:17 +0530, Balavasu wrote:
> This patch fixes the checkpatch.pl issue
> WARNING: memcpy(dev->dev_addr, mac, ETH_ALEN);

That is not the actual warning.

This is the warning:

Prefer ether_addr_copy() over memcpy() if the Ethernet addresses are __aligned(2)

How have you made sure that mac can not have odd alignment?

Make sure your commit message shows how you know
that mac is appropriately aligned.

> diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
[]
> @@ -452,7 +452,7 @@ int cvm_oct_common_init(struct net_device *dev)
>  		mac = of_get_mac_address(priv->of_node);
>  
>  	if (mac)
> -		memcpy(dev->dev_addr, mac, ETH_ALEN);
> +		ether_addr_copy(dev->dev_addr, mac);
>  	else
>  		eth_hw_addr_random(dev);
>  
