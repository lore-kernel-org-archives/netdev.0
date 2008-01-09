From: patnel972-linux@yahoo.fr
Subject: Re : Re : Bonding : Monitoring of 4965 wireless card
Date: Wed, 9 Jan 2008 21:17:06 +0000 (GMT)
Message-ID: <168648.20508.qm@web25705.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25705.mail.ukl.yahoo.com ([217.12.10.177]:22361 "HELO
	web25705.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750825AbYAIVRJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 16:17:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ignore it, but it seems like it prevent bonding detect link of wlan0.=
 I enslave wlan0 and i already use use_carrier=3D1;
I use bond to have my etherenet ip in wifi at office, else the wireless=
 connection give temporary and you must pass through proxy then.
I'll try arp monitoring but this is annoying i c'ant test localhost. Is=
 there a way to test localhost with arp, without pass through lo ?=20



----- Message d'origine ----
De : John W. Linville <linville@tuxdriver.com>
=C0 : patnel972-linux@yahoo.fr
Envoy=E9 le : Mercredi, 9 Janvier 2008, 21h24mn 10s
Objet : Re: Re : Bonding : Monitoring of 4965 wireless card

On Wed, Jan 09, 2008 at 07:31:37PM +0000, patnel972-linux@yahoo.fr
 wrote:
> I'm doing a bonding with my eth0(e1000 driver) and my wlan
> card(iwl4965). It work like i want, when i'm in wifi the dhcp give
> me my ethernet adress. When i unplug the cable, my wlan card become
> in charge of network. My problem is when i disconnect the wlan card,
> the bonding does not detect it correctly, and ifplugstatus show me
> wlan0 not connected and wmaster0 connected!! The bonding module does
> not say no active interface, it work like wlan is on.
>=20
> Am i clear?

Yes, that is much more clear to me.

What (if anything) are you doing to wmaster0?  You should just
ignore it.

=46WIW, miimon is not going to work with a mac80211-based device at
this time.  The miimon option relies on support for either miitool
or ethtool, and mac80211 device support neither of those.

Hmmm...it looks like there is a use_carrier option for miimon.
Based on its description I would think it would work.  Of course,
I think it is supposed to be the default and you don't seem to be
disabling it.  So, I'm not sure what is happening.

Are you enslaving wlan0?  Or wmaster0?  Make sure it is wlan0.
Also, please add use_carrier=3D1 to your bonding module options.
Does this change the behaviour?  If not, please open a bug at either
bugzilla.redhat.com (if you are a Fedora, RHEL, or even CentOS user)
or bugzilla.kernel.org (otherwise).

In the meantime, you might try using NetworkManger.  Or you
might consider using ARP monitoring.  The former probably is the
best solution if you are mobile (e.g.  at a cafe or other hotspot)
while the latter might be appropriate if you are just plugging and
un-plugging within the same network (like at home or office).

Hth!

John
--=20
John W. Linville
linville@tuxdriver.com





      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail http://mail.yahoo.fr
