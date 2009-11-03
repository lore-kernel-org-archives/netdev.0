From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] usbnet: Do not implement ethtool get_link() if link state is unknown
Date: Mon, 2 Nov 2009 23:01:30 -0700
Message-ID: <200911022201.30950.david-b@pacbell.net>
References: <1257218818.3136.440.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	David Brownell <dbrownell@users.sourceforge.net>,
	"Greg Kroah-Hartman" <greg@kroah.com>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.sbc.mail.gq1.yahoo.com ([67.195.14.111]:22740 "HELO
	smtp108.sbc.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751523AbZKCGIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 01:08:07 -0500
In-Reply-To: <1257218818.3136.440.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 02 November 2009, Ben Hutchings wrote:
> @@ -854,7 +854,7 @@ void usbnet_set_msglevel (struct net_device *net,=
 u32 level)
> =A0EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
> =A0
> =A0/* drivers may override default ethtool_ops in their bind() routin=
e */
> -static const struct ethtool_ops usbnet_ethtool_ops =3D {
> +static const struct ethtool_ops usbnet_get_link_ethtool_ops =3D {
> =A0=A0=A0=A0=A0=A0=A0=A0.get_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_get_settings,
> =A0=A0=A0=A0=A0=A0=A0=A0.set_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_set_settings,
> =A0=A0=A0=A0=A0=A0=A0=A0.get_link=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=3D usbnet_get_link,
> @@ -864,6 +864,15 @@ static const struct ethtool_ops usbnet_ethtool_o=
ps =3D {
> =A0=A0=A0=A0=A0=A0=A0=A0.set_msglevel=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_set_msglevel,
> =A0};
> =A0
> +static const struct ethtool_ops usbnet_ethtool_ops =3D {
> +=A0=A0=A0=A0=A0=A0=A0.get_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D=
 usbnet_get_settings,
> +=A0=A0=A0=A0=A0=A0=A0.set_settings=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D=
 usbnet_set_settings,

Surely there's a code that usbnet_get_link() could return
to say "I can't really tell"?

And if there isn't, there should be one.

Having two tables for this is needlessly ugly.

> +=A0=A0=A0=A0=A0=A0=A0.nway_reset=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=3D usbnet_nway_reset,
> +=A0=A0=A0=A0=A0=A0=A0.get_drvinfo=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=3D usbnet_get_drvinfo,
> +=A0=A0=A0=A0=A0=A0=A0.get_msglevel=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D=
 usbnet_get_msglevel,
> +=A0=A0=A0=A0=A0=A0=A0.set_msglevel=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D=
 usbnet_set_msglevel,
> +};
> +
> =A0/*----------------------------------------------------------------=
---------*/
> =A0
> =A0/* work that cannot be done in interrupt context uses keventd.


