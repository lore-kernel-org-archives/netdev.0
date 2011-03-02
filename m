From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 2 Mar 2011 19:01:39 +0100
Message-ID: <201103021901.39849.florian@openwrt.org>
References: <20110302163233.GA14491@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Alex G." <mr.nuke.me@gmail.com>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50591 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182Ab1CBSA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 13:00:29 -0500
Received: by wyg36 with SMTP id 36so248768wyg.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 10:00:28 -0800 (PST)
In-Reply-To: <20110302163233.GA14491@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wednesday 02 March 2011 17:32:33 Roger Luethi wrote:
> From: "Alex G." <mr.nuke.me@gmail.com>
> 
> via-rhine drops out of the init code if the hardware provides an invalid
> MAC address. I have several reports of Rhine NICs doing just that. The
> hardware still works, though; continuing the init process gives the user a
> chance to fix the MAC address using "ifconfig ethX hw ether" which appears
> to result in a perfectly useable network adapter.
> 
> Most recent report and patch provided by Alex G.
> 
> Signed-off-by: "Alex G." <mr.nuke.me@gmail.com>
> Signed-off-by: Roger Luethi <rl@hellgate.ch>
> 
> diff --git a/linux-2.6.35.11/drivers/net/via-rhine.c b/via-rhine.c
> index 4930f9d..a1189f4 100644
> --- a/linux-2.6.35.11/drivers/net/via-rhine.c
> +++ b/via-rhine.c
> @@ -766,8 +766,12 @@ static int __devinit rhine_init_one(struct pci_dev
> *pdev,
> 
>  	if (!is_valid_ether_addr(dev->perm_addr)) {
>  		rc = -EIO;
> -		printk(KERN_ERR "Invalid MAC address\n");
> -		goto err_out_unmap;
> +		printk(KERN_ERR "via-rhine: invalid MAC address: %pM. "
> +				"Use ifconfig to configure valid address.\n",
> +				dev->dev_addr);
> +		/* The device may still be used normally if a valid MAC is 
configured
> +		 * We do not consider this a fatal error, and continue 
initialization
> +		 */
>  	}

Why not generate a valid random ethernet address using random_ether_addr() 
instead?
--
Florian
