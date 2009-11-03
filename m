From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Do not implement ethtool get_link() if link
 state is unknown
Date: Tue, 03 Nov 2009 01:01:29 -0800 (PST)
Message-ID: <20091103.010129.100672838.davem@davemloft.net>
References: <1257218818.3136.440.camel@localhost>
	<200911022201.30950.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, dbrownell@users.sourceforge.net,
	greg@kroah.com, jacmet@sunsite.dk, steve.glendinning@smsc.com,
	netdev@vger.kernel.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59703
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753343AbZKCJBF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 04:01:05 -0500
In-Reply-To: <200911022201.30950.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Brownell <david-b@pacbell.net>
Date: Mon, 2 Nov 2009 23:01:30 -0700

> On Monday 02 November 2009, Ben Hutchings wrote:
>> @@ -854,7 +854,7 @@ void usbnet_set_msglevel (struct net_device *net=
, u32 level)
>> =A0EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
>> =A0
>> =A0/* drivers may override default ethtool_ops in their bind() routi=
ne */
>> -static const struct ethtool_ops usbnet_ethtool_ops =3D {
>> +static const struct ethtool_ops usbnet_get_link_ethtool_ops =3D {
>> =A0=A0=A0=A0=A0=A0=A0=A0.get_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_get_settings,
>> =A0=A0=A0=A0=A0=A0=A0=A0.set_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_set_settings,
>> =A0=A0=A0=A0=A0=A0=A0=A0.get_link=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=3D usbnet_get_link,
>> @@ -864,6 +864,15 @@ static const struct ethtool_ops usbnet_ethtool_=
ops =3D {
>> =A0=A0=A0=A0=A0=A0=A0=A0.set_msglevel=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_set_msglevel,
>> =A0};
>> =A0
>> +static const struct ethtool_ops usbnet_ethtool_ops =3D {
>> +=A0=A0=A0=A0=A0=A0=A0.get_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_get_settings,
>> +=A0=A0=A0=A0=A0=A0=A0.set_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_set_settings,
>=20
> Surely there's a code that usbnet_get_link() could return
> to say "I can't really tell"?
>=20
> And if there isn't, there should be one.

Having a NULL operations pointer for this function is how to
indicate this.  It's a static situation based upon the device
type, not a dynamic one which would be resolved at run time
when inspecting the device registers for example.

> Having two tables for this is needlessly ugly.

Yes, it's really cruddy how the USB network driver tries to share
so much state amongst such very different devices :-)

All kidding aside, I think the alternative is for the USB network
driver to call ethtool_op_get_link() if it cannot determine the
link state in hardware.

