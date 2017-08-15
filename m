From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 06/11] net: dsa: debugfs: add port registers
Date: Tue, 15 Aug 2017 16:28:12 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AFD219@CHN-SV-EXMX02.mchp-main.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <kernel@savoirfairelinux.com>,
        <davem@davemloft.net>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <privat@egil-hjelmeland.no>, <john@phrozen.org>,
        <sean.wang@mediatek.com>, <volodymyr.bendiuga@gmail.com>,
        <nikita.yoush@cogentembedded.com>, <maxime@devialet.com>,
        <cphealy@gmail.com>, <muvarov@gmail.com>, <eichest@gmail.com>,
        <jcobham@questertangent.com>, <jbe@pengutronix.de>,
        <tobias@waldekranz.com>
To: <vivien.didelot@savoirfairelinux.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-7-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vivien,

> Subject: [PATCH net-next 06/11] net: dsa: debugfs: add port registers
> 
> Add a debug filesystem "regs" entry to query a port's hardware registers
> through the .get_regs_len and .get_regs_len switch operations.
> 
> This is very convenient because it allows one to dump the registers of
> DSA links, which are not exposed to userspace.
This series will be very useful to get various debug information.
Do you have any plan to expand 32bit register access and switch-level registers
In addition to port-level registers?

> +static void dsa_debugfs_regs_read_count(struct dsa_switch *ds, int id,
> +					struct seq_file *seq, int count)
> +{
> +	u16 data[count * ETH_GSTRING_LEN];
I think this should be u16 data[count] because it is value of registers.

> +	struct ethtool_regs regs;
> +	int i;
> +
> +	ds->ops->get_regs(ds, id, &regs, data);
> +
> +	for (i = 0; i < count / 2; i++)
> +		seq_printf(seq, "%2d: %04x\n", i, data[i]);
> +}
> +
> +static int dsa_debugfs_regs_read(struct dsa_switch *ds, int id,
> +				 struct seq_file *seq)
> +{
> +	int count;
> +
> +	if (!ds->ops->get_regs_len || !ds->ops->get_regs)
> +		return -EOPNOTSUPP;
> +
> +	count = ds->ops->get_regs_len(ds, id);
> +	if (count < 0)
> +		return count;
Because get_regs_len returns length than count per mv88e6xxx/chip.c,
it requires some math before passing to dsa_debugfs_regs_read_count().

It does "count/2" in dsa-debugfs_regs_read_count(), however,
As commented above, "count" is used at "u16 data[...]".
So, it would be nice to match with name. Ie, count or size/length.

Thanks.
Woojung
