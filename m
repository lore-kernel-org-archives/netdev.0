From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 02/11] net: dsa: add debugfs interface
Date: Tue, 15 Aug 2017 10:29:04 -0700
Message-ID: <2c13f5a3-0cc6-fe1a-86fc-c5bfd8cc2263@gmail.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/14/2017 03:22 PM, Vivien Didelot wrote:
> This commit adds a DEBUG_FS dependent DSA core file creating a generic
> debug filesystem interface for the DSA switch devices.
> 
> The interface can be mounted with:
> 
>     # mount -t debugfs none /sys/kernel/debug
> 
> The dsa directory contains one directory per switch chip:
> 
>     # cd /sys/kernel/debug/dsa/
>     # ls
>     switch0  switch1 switch2
> 
> Each chip directory contains one directory per port:
> 
>     # ls -l switch0/
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port0
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port1
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port2
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port5
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port6
> 
> Future patches will add entry files to these directories.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---

> +static int dsa_debugfs_create_switch(struct dsa_switch *ds)
> +{
> +	char name[32];
> +	int i;
> +
> +	/* skip if there is no debugfs support */
> +	if (!dsa_debugfs_dir)
> +		return 0;
> +
> +	snprintf(name, sizeof(name), DSA_SWITCH_FMT, ds->index);
> +
> +	ds->debugfs_dir = debugfs_create_dir(name, dsa_debugfs_dir);
> +	if (IS_ERR_OR_NULL(ds->debugfs_dir))
> +		return -EFAULT;
> +
> +	for (i = 0; i < ds->num_ports; i++) {
> +		if (!ds->ports[i].dn)
> +			continue;

This won't create port directories when using platform data, can you
check for BIT(i) & ds->enabled_port_mask instead?
-- 
Florian
