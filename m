From: Moni Shoua <monis@Voltaire.COM>
Subject: Re: [PATCH]  net/bonding: Don't destroy bonding master wehn unensalving
 with a sysfs command
Date: Wed, 25 Jun 2008 17:08:40 +0300
Message-ID: <48625168.5090703@Voltaire.COM>
References: <485A74D1.10900@Voltaire.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Olga Stern <olgas@voltaire.com>, netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:29299 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755995AbYFYOIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 10:08:53 -0400
In-Reply-To: <485A74D1.10900@Voltaire.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moni Shoua wrote:
> It is wrong to destroy a bonding  master from a context that uses the sysfs of
>  that bond. When last IPoIB slave is unenslaved from by writing to a sysfs
>  file (for bond0 this would be /sys/class/net/bond0/bonding/slaves) the driver
>  tries to destroy the bond. This is wrong and can lead to a lockup or a crash.
>  This fix lets the bonding master stay and relies on the user to destroy the
>  bonding master if necessary (i.e. before module ib_ipoib is unloaded)
> 
> This patch affects only bonds of IPoIB slaves. Ethernet slaves stay unaffected.
> Signed-off-by: Moni Shoua <monis@voltaire.com>
> ---
>  drivers/net/bonding/bond_sysfs.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 08f3d39..f66f590 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -351,9 +351,6 @@ static ssize_t bonding_store_slaves(struct device *d,
>  		if (dev) {
>  			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
>  				bond->dev->name, dev->name);
> -			if (bond->setup_by_slave)
> -				res = bond_release_and_destroy(bond->dev, dev);
> -			else
>  				res = bond_release(bond->dev, dev);
>  			if (res) {
>  				ret = res;
Hi Jay,
Could you please refer to this one?
