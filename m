From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 net-next 3/5] dsa: add DSA switch driver for
 Microchip KSZ9477
Date: Mon, 15 May 2017 21:01:02 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A654D1@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40A632C2@CHN-SV-EXMX02.mchp-main.com>
 <20170513131341.GC14058@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <vivien.didelot@savoirfairelinux.com>,
        <sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:23363 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdEOVBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 17:01:03 -0400
In-Reply-To: <20170513131341.GC14058@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static const struct ksz_chip_data ksz_switch_chips[] = {
> > +	{
> > +		.chip_id = 0x00947700,
> > +		.dev_name = "KSZ9477",
> > +		.num_vlans = 4096,
> > +		.num_alus = 4096,
> > +		.num_statics = 16,
> > +		.enabled_ports = 0x1F,	/* port0-4 */
> > +		.cpu_port = 5,		/* port5 (RGMII) */
> > +		.port_cnt = 7,
> > +		.phy_port_cnt = 5,
> > +	},
> > +};
> 
> Hi Woojung
> 
> Do we need cpu_port in this table? Can any port be used as a CPU port?
> From the code in ksz_config_cpu_port() it seems like it can.
> 
> And do we need enabled_ports? This seems to suggest only ports 0-4 can
> be user ports?
> 
Andrew,

Intention of cpu_port is for default cpu_port when devicetree doesn't have it.
However, it won't get back to dst, so it won't be needed.
Will remove it.

Enabled_ports was to configure physically connected ports. (For instance, 7 ports switch but board only uses 4 ports.)
This code path is not working as expected. Will update at next version of patch.

Thanks.
Woojung
