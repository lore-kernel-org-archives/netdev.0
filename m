From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/6] net: dsa: add port_fdb_dump function
Date: Wed, 14 Oct 2015 06:12:20 -0700 (PDT)
Message-ID: <20151014.061220.710919703136753197.davem@davemloft.net>
References: <1444754783-26975-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<1444754783-26975-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444754783-26975-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 13 Oct 2015 12:46:18 -0400

> @@ -198,7 +198,9 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
>  }
>  
>  struct switchdev_trans;
> +struct switchdev_obj;
>  struct switchdev_obj_port_fdb;
> +typedef int switchdev_obj_dump_cb_t(struct switchdev_obj *obj);
>  
>  struct dsa_switch_driver {
>  	struct list_head	list;
 ...
> @@ -382,6 +382,9 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
>  	u16 vid = 0;
>  	int ret;
>  
> +	if (ds->drv->port_fdb_dump)
> +		return ds->drv->port_fdb_dump(ds, p->port, fdb, cb);
> +
>  	if (!ds->drv->port_fdb_getnext)

I realize you're fighting include file dependency issues, but this is
rediculous.  Now you're using two different typedefs for this callback
function pointer.

This is why typedef's suck.

We should just opencode "int (*cb)(struct switchdev_obj *)" everywhere
and kill these typedefs which are obviously just getting in the way
and making us do silly things.
