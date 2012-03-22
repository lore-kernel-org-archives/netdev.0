From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ethernet driver for the WIZnet W5300 chip
Date: Thu, 22 Mar 2012 16:57:29 +0000
Message-ID: <1332435449.2461.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1332149037-12025-1-git-send-email-msink@permonline.ru>
	 <1332266881.2489.4.camel@bwh-desktop.uk.solarflarecom.com>
	 <4F69734B.7040105@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15000 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754967Ab2CVQ5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 12:57:37 -0400
In-Reply-To: <4F69734B.7040105@permonline.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-21 at 12:20 +0600, Mike Sinkovsky wrote:
> 21.03.2012 0:08, Ben Hutchings =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=
=BB:
> > +static void w5300_get_drvinfo(struct net_device *ndev,
> > +			      struct ethtool_drvinfo *info)
> > +{
> > +	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
> > +	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
> > +	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
> > [...]
> >
> > Nitpick: if you don't have firmware, don't set fw_version at all.
> >
> > Ben.
>=20
> Then ethtool prints empty string as firmware version, I think "N/A" i=
s=20
> more intuitive.

Well, we can replace it with "N/A" in ethtool if that's what people wan=
t
to see.  But it should not be necessary for every driver that can't
report a firmware version to write this special string.

> Can will remove, if it is preferred way.

It is, and the various other drivers that used this string have recentl=
y
been changed.

> But I have a question to networking guru's:
>=20
> This chip have FRAME_SIZE limited to 1514, including eth header.
> So, for 802.1Q vlan packets mtu must be set to 1496.
>
> For now we handle this from userspace, but I think this is wrong in g=
eneral
> - handling hardware bugs and limitations is kernels job.
>=20
> Can driver somehow limit mtu for slave vlan devices to 1496, but stil=
l=20
> use 1500
> for plain ethernet?
> ->ndo_change_mtu is called for master device only, not for it's slave=
s.

I don't think it's possible to do this at the moment.  You can only set
NETIF_F_VLAN_CHALLENGED, which unfortunately disables VLAN sub-devices
entirely.

> (and sorry for my russian english, just in case)

Not to worry - your writing is quite clear.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
