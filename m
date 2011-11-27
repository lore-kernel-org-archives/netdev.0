From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH net-next 2/8] dsa: Export functions from core to modules
Date: Sun, 27 Nov 2011 20:15:56 +0100
Message-ID: <20111127191556.GQ795@wantstofly.org>
References: <1322267572.2839.381.camel@deadeye>
 <1322267647.2839.382.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:49273 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab1K0TZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 14:25:59 -0500
Content-Disposition: inline
In-Reply-To: <1322267647.2839.382.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2011 at 12:34:07AM +0000, Ben Hutchings wrote:

> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  net/dsa/dsa.c   |    2 ++
>  net/dsa/slave.c |    2 ++
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 66f5c04..fc93088 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -29,6 +29,7 @@ void register_switch_driver(struct dsa_switch_driver *drv)
>  	list_add_tail(&drv->list, &dsa_switch_drivers);
>  	mutex_unlock(&dsa_switch_drivers_mutex);
>  }
> +EXPORT_SYMBOL_GPL(register_switch_driver);
>  
>  void unregister_switch_driver(struct dsa_switch_driver *drv)
>  {
> @@ -36,6 +37,7 @@ void unregister_switch_driver(struct dsa_switch_driver *drv)
>  	list_del_init(&drv->list);
>  	mutex_unlock(&dsa_switch_drivers_mutex);
>  }
> +EXPORT_SYMBOL_GPL(unregister_switch_driver);
>  
>  static struct dsa_switch_driver *
>  dsa_switch_probe(struct mii_bus *bus, int sw_addr, char **_name)

ACK on these.


> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 56cf9b8..c9d52ca 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -45,6 +45,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
>  			ds->master_mii_bus->id, ds->pd->sw_addr);
>  	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
>  }
> +EXPORT_SYMBOL_GPL(dsa_slave_mii_bus_init);
>  
> 
>  /* slave device handling ****************************************************/
> @@ -402,3 +403,4 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  
>  	return slave_dev;
>  }
> +EXPORT_SYMBOL_GPL(dsa_slave_create);

Why do these need to be exported?  They are only called from dsa.c,
and dsa.c and slave.c are always linked into the same entity, even
after your patches.
