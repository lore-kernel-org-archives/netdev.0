From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 09/13] net-caif: add CAIF netdevice
Date: Tue, 02 Feb 2010 15:17:57 +0100
Message-ID: <4B683415.9030708@trash.net>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-10-git-send-email-sjur.brandeland@stericsson.com> <4B580A39.3000805@trash.net> <61D8D34BB13CFE408D154529C120E079032A2145@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: =?ISO-8859-15?Q?Sjur_Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63416 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755943Ab0BBOR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 09:17:59 -0500
In-Reply-To: <61D8D34BB13CFE408D154529C120E079032A2145@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sjur Br=E6ndeland wrote:
>>> +	if (priv->config.type =3D=3D CAIF_CHTY_DATAGRAM_LOOP) { +		struct
>>> iphdr *hdr; +		__be32 swap;
>>> +		/* Retrieve IP header. */
>>> +		hdr =3D ip_hdr(skb);
>>> +		/* Change source and destination address. */
>>> +		swap =3D hdr->saddr;
>>> +		hdr->saddr =3D hdr->daddr;
>>> +		hdr->daddr =3D swap;
>> swap()?
>=20
>=20
> The modem provides a loopback function for the CAIF link type (CAIF_C=
HTY_DATAGRAM_LOOP).
> This is useful for testing the physical link between modem and host.
> In this scenario we need to swap src and destination ip address.
> I'll move this to a separate function in next patch set.

There is already a swap() function which you can use.

>>> +static int ipcaif_newlink(struct net *src_net, struct net_device
>>> *dev, +			  struct nlattr *tb[], struct nlattr *data[]) { +	int err=
;
>>> +	struct chnl_net *caifdev;
>>> +	ASSERT_RTNL();
>>> +	caifdev =3D netdev_priv(dev);
>>> +	caif_netlink_parms(data, &caifdev->config);
>>> +	err =3D register_netdevice(dev);
>>> +	if (err) {
>>> +		pr_warning("CAIF: %s(): device rtml registration failed\n", +			=
=20
>>> __func__); +		goto out;
>>> +	}
>>> +	dev_hold(dev);
>> What is this reference used for? You don't have a dellink function,
>> so this looks like a leak.=20
>=20
> I don't think it leaks because I do dev_put in chnl_net_uninit,
> but you're right - I don't really need this. I'll remove the=20
> dev_hold and dev_put completely in next patch-set.

But it wouldn't get released when deleting a link using netlink
I think since without a dellink function I don't see what would
invoke chnl_net_uninit(). Anyways, removing it will fix this :)
