From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 2/2] cxgb4: Add support for ndo_get_vf_config
Date: Wed, 24 Aug 2016 13:28:49 +0530
Message-ID: <20160824075848.GA9955@hari-Latitude-E5550>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
 <1472021434-8287-3-git-send-email-hariprasad@chelsio.com>
 <SN2PR11MB0094F2A207BDF5404D6BCDD597EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:59412 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751025AbcHXH7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 03:59:55 -0400
Content-Disposition: inline
In-Reply-To: <SN2PR11MB0094F2A207BDF5404D6BCDD597EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, August 08/24/16, 2016 at 07:15:49 +0000, Yuval Mintz wrote:
> > +static void fill_vf_station_mac_addr(struct adapter *adap)
> > +{
> > +	unsigned int i;
> > +	u8 hw_addr[ETH_ALEN], macaddr[ETH_ALEN];
> > +	int err;
> > +	u8 *na;
> > +	u16 a, b;
> > +
> > +	err = t4_get_raw_vpd_params(adap, &adap->params.vpd);
> > +	if (!err) {
> > +		na = adap->params.vpd.na;
> > +		for (i = 0; i < ETH_ALEN; i++)
> > +			hw_addr[i] = (hex2val(na[2 * i + 0]) * 16 +
> > +				      hex2val(na[2 * i + 1]));
> > +		a = (hw_addr[0] << 8) | hw_addr[1];
> > +		b = (hw_addr[1] << 8) | hw_addr[2];
> > +		a ^= b;
> > +		a |= 0x0200;    /* locally assigned Ethernet MAC address */
> > +		a &= ~0x0100;   /* not a multicast Ethernet MAC address */
> > +		macaddr[0] = a >> 8;
> > +		macaddr[1] = a & 0xff;
> > +
> > +		for (i = 2; i < 5; i++)
> > +			macaddr[i] = hw_addr[i + 1];
> > +
> > +		for (i = 0; i < adap->num_vfs; i++) {
> > +			macaddr[5] = adap->pf * 16 + i;
> > +			ether_addr_copy(adap->vfinfo[i].vf_mac_addr,
> > macaddr);
> > +		}
> > +	}
> > +}
> 
> That's some... magical magic? :-)
> But I couldn't see anywhere in the patch where this MAC is propagated
> to the VF, only to the new NDO(). Care to explain how does the VF learn it?
> 	
The same logic is used by the firmware to generate the MAC address for the VF.
If MAC address isn't provided through IFLA_VF_MAC. This function is only used
to populate the stationary MAC's for the VF, when user hasn't provided one.

-Hari
