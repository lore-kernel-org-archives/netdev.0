From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Sat, 13 May 2017 15:13:41 +0200
Message-ID: <20170513131341.GC14058@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A632C2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        davem@davemloft.net, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57648 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdEMNNq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 13 May 2017 09:13:46 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A632C2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 08:07:58PM +0000, Woojung.Huh@microchip.com wrote:

> +static void ksz_config_cpu_port(struct dsa_switch *ds)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	int i;
> +
> +	ds->num_ports = dev->port_cnt;
> +
> +	for (i = 0; i < ds->num_ports; i++) {
> +		if (dsa_is_cpu_port(ds, i)) {
> +			dev->cpu_port = i;
> +			/* enable tag tail for host port */
> +			ksz_port_cfg(dev, i, REG_PORT_CTRL_0,
> +				     PORT_TAIL_TAG_ENABLE, true);
> +		}
> +	}
> +}


> +static const struct ksz_chip_data ksz_switch_chips[] = {
> +	{
> +		.chip_id = 0x00947700,
> +		.dev_name = "KSZ9477",
> +		.num_vlans = 4096,
> +		.num_alus = 4096,
> +		.num_statics = 16,
> +		.enabled_ports = 0x1F,	/* port0-4 */
> +		.cpu_port = 5,		/* port5 (RGMII) */
> +		.port_cnt = 7,
> +		.phy_port_cnt = 5,
> +	},
> +};

Hi Woojung

Do we need cpu_port in this table? Can any port be used as a CPU port?
>From the code in ksz_config_cpu_port() it seems like it can.

And do we need enabled_ports? This seems to suggest only ports 0-4 can
be user ports?

Thanks
	Andrew
