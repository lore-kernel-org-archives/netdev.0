From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V2 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Wed, 14 Sep 2016 17:47:53 +0200
Message-ID: <12cdce62-b5a4-c423-2532-d86f159d3be6@phrozen.org>
References: <1473849542-3298-1-git-send-email-john@phrozen.org>
 <1473849542-3298-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473849542-3298-4-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 14/09/2016 12:39, John Crispin wrote:
> +static void
> +qca8k_fdb_add(struct dsa_switch *ds, int port,
> +	      const struct switchdev_obj_port_fdb *fdb,
> +	      struct switchdev_trans *trans)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +	u16 port_mask = BIT(port);
> +	u16 vid = fdb->vid;
> +
> +	if (!vid)
> +		vid = 1;
> +
> +	qca8k_fdb_write(priv, vid, port_mask, fdb->addr,
> +			QCA8K_ATU_STATUS_STATIC);
> +
> +	qca8k_fdb_access(priv, QCA8K_FDB_LOAD, -1);
> +}
> +
> +static int
> +qca8k_fdb_del(struct dsa_switch *ds, int port,
> +	      const struct switchdev_obj_port_fdb *fdb)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +	u16 port_mask = BIT(port);
> +
> +	qca8k_fdb_write(priv, fdb->vid, port_mask, fdb->addr, 0);
> +
> +	return qca8k_fdb_access(priv, QCA8K_FDB_PURGE, -1);
> +}
> +

while adding MDB support i noticed that

1) the code above is still not properly locked
2) i can unify the FDB and MDB code

i will send a V3 with those 2 changes tomorrow.

	John
