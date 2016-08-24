From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 2/2] cxgb4: Add support for ndo_get_vf_config
Date: Wed, 24 Aug 2016 07:15:49 +0000
Message-ID: <SN2PR11MB0094F2A207BDF5404D6BCDD597EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
 <1472021434-8287-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0108.outbound.protection.outlook.com ([104.47.34.108]:24736
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753080AbcHXHQA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 03:16:00 -0400
In-Reply-To: <1472021434-8287-3-git-send-email-hariprasad@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void fill_vf_station_mac_addr(struct adapter *adap)
> +{
> +	unsigned int i;
> +	u8 hw_addr[ETH_ALEN], macaddr[ETH_ALEN];
> +	int err;
> +	u8 *na;
> +	u16 a, b;
> +
> +	err =3D t4_get_raw_vpd_params(adap, &adap->params.vpd);
> +	if (!err) {
> +		na =3D adap->params.vpd.na;
> +		for (i =3D 0; i < ETH_ALEN; i++)
> +			hw_addr[i] =3D (hex2val(na[2 * i + 0]) * 16 +
> +				      hex2val(na[2 * i + 1]));
> +		a =3D (hw_addr[0] << 8) | hw_addr[1];
> +		b =3D (hw_addr[1] << 8) | hw_addr[2];
> +		a ^=3D b;
> +		a |=3D 0x0200;    /* locally assigned Ethernet MAC address */
> +		a &=3D ~0x0100;   /* not a multicast Ethernet MAC address */
> +		macaddr[0] =3D a >> 8;
> +		macaddr[1] =3D a & 0xff;
> +
> +		for (i =3D 2; i < 5; i++)
> +			macaddr[i] =3D hw_addr[i + 1];
> +
> +		for (i =3D 0; i < adap->num_vfs; i++) {
> +			macaddr[5] =3D adap->pf * 16 + i;
> +			ether_addr_copy(adap->vfinfo[i].vf_mac_addr,
> macaddr);
> +		}
> +	}
> +}

That's some... magical magic? :-)
But I couldn't see anywhere in the patch where this MAC is propagated
to the VF, only to the new NDO(). Care to explain how does the VF learn it?
=09
