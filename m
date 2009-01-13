From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] SIS900 show warning if bogus MAC address (take 2)
Date: Tue, 13 Jan 2009 15:44:07 -0800
Message-ID: <20090113154407.9d2fe57c.akpm@linux-foundation.org>
References: <20090113181821.GA21342@milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, venza@brownhat.org
To: Daniele Venzano <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44873 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758253AbZAMXoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:44:18 -0500
In-Reply-To: <20090113181821.GA21342@milesteg.arr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jan 2009 19:18:21 +0100
Daniele Venzano <venza@brownhat.org> wrote:
>
> Subject: [PATCH] SIS900 show warning if bogus MAC address (take 2)
>

The title is now wrong.  I rewrote it in my copy to

sis900: generate fake MAC address if the hardware doesn't have one

> The attached patch modifies the sis900 driver when the MAC address
> read from the hardware is invalid. As suggested, the patch now
> generates a random address so that the user can go on and use
> the hardware. In any case a message is also shown to warn on the
> unexpected condition.
> This seems to happen with newer HW implementation of the sis900
> chipset, since this never came up before.
> 
> Patch is against vanilla 2.6.28 (but the driver doesn't change so often,
> so it will probably apply to older/newer versions too).
> 
> See bugzilla ID 10201 and 11649 and ignore the previous patch.

When referring to bugzilla reports I like to use the full URL.  It's
simpler for readers and makes life easier for those people who search
changelogs looking for bug reports to close off.

> diff -puN drivers/net/sis900.c~sis900-generate-fake-mac-address-if-the-hardware-doesnt-have-one drivers/net/sis900.c
> --- a/drivers/net/sis900.c~sis900-generate-fake-mac-address-if-the-hardware-doesnt-have-one
> +++ a/drivers/net/sis900.c
> @@ -509,10 +509,10 @@ static int __devinit sis900_probe(struct
>  	else
>  		ret = sis900_get_mac_addr(pci_dev, net_dev);
>  
> -	if (ret == 0) {
> -		printk(KERN_WARNING "%s: Cannot read MAC address.\n", dev_name);
> -		ret = -ENODEV;
> -		goto err_unmap_rx;
> +	if (!ret || !is_valid_ether_addr(net_dev->dev_addr)) {
> +		random_ether_addr(net_dev->dev_addr);
> +		printk(KERN_WARNING "%s: Unreadable or invalid MAC address,"
> +				"using random generated one\n", dev_name);

So we generate the fake address a) if the reading failed and b) if the
reading succeeded, but returned a bad address.

Fair enough, I guess.  I wonder if other drivers implement that policy.

