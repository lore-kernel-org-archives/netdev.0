From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v4 net-next 3/5] dsa: add DSA switch driver for
 Microchip KSZ9477
Date: Tue, 30 May 2017 23:10:17 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA4CE7@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40AA459F@CHN-SV-EXMX02.mchp-main.com>
 <20170530223544.GB9707@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:50294 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbdE3XKa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 19:10:30 -0400
In-Reply-To: <20170530223544.GB9707@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
> > +static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
> > +			    const struct switchdev_obj_port_mdb *mdb)
> > +{
> > +	struct ksz_device *dev = ds->priv;
> > +	u32 static_table[4];
> > +	u32 data;
> > +	int index;
> > +	int ret = 0;
> > +	u32 mac_hi, mac_lo;
> > +
> > +	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
> > +	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
> > +	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
> > +
> > +	mutex_lock(&dev->alu_mutex);
> > +
> > +	for (index = 0; index < dev->num_statics; index++) {
> > +		/* find empty slot first */
> > +		data = (index << ALU_STAT_INDEX_S) |
> > +			ALU_STAT_READ | ALU_STAT_START;
> > +		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
> > +
> > +		/* wait to be finished */
> > +		ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
> > +		if (ret < 0) {
> > +			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
> > +			goto exit;
> > +		}
> > +
> > +		/* read ALU static table */
> > +		read_table(ds, static_table);
> > +
> > +		mutex_unlock(&dev->alu_mutex);
> 
> Is this mutex unlock here correct? It looks like we will unlock it
> again when we eventually get to exit: below.
> 
Thanks for catching this. Will submit new patch soon.

- Woojung
