From: Erik Mouw <mouw@nl.linux.org>
Subject: Re: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Tue, 29 Jan 2008 22:45:56 +0100
Message-ID: <20080129214555.GC29300@gateway.home>
References: <20080129184726.GA29300@gateway.home> <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com> <1201640243.4431.29.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="48TaNjbzBVislYPb"
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr15.xs4all.nl ([194.109.24.35]:2938 "EHLO
	smtp-vbr15.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbYA2VqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 16:46:09 -0500
Content-Disposition: inline
In-Reply-To: <1201640243.4431.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--48TaNjbzBVislYPb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 29, 2008 at 03:57:23PM -0500, jamal wrote:
> On Tue, 2008-29-01 at 11:57 -0800, Waskiewicz Jr, Peter P wrote:
> > > I've just started to use 2.6.24 on my home firewall (before=20
> > > it was running 2.6.24-rc2 for about 65 days) and I noticed a=20
> > > couple of error messages I've never seen before:
> > >=20
> > > Jan 29 07:50:54 gateway kernel: BUG eth1 code -5 qlen 0 Jan=20
> > > 29 08:28:30 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29=20
> > > 08:57:30 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29=20
> > > 09:44:04 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29=20
> > > 10:01:35 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29=20
> > > 10:01:35 gateway last message repeated 2 times Jan 29=20
> > > 10:16:48 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29=20
> > > 10:16:48 gateway last message repeated 2 times Jan 29=20
> > > 10:45:48 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29=20
> > > 10:45:48 gateway last message repeated 2 times Jan 29=20
> > > 11:10:01 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29=20
> > > 11:10:02 gateway last message repeated 9 times
> > >=20
> > > The message seems to be coming from the qdisc_restart() in=20
> > > net/sched/sch_generic.c which was changed with commit=20
> > > 5f1a485d5905aa641f33009019b3699076666a4c .
> > >=20
> > > The NIC is an IBM EtherJet cardbus card using the xircom_cb driver:
> >=20
> > Are you using any specific qdisc, or just the default pfifo_fast?  Have
> > you done any specific tuning on your qdisc as well?  The default qlen
> > seems to have been changed.
>=20
> The driver seems buggy. Make it return NETDEV_TX_BUSY instead of -EIO
> in xircom_start_xmit() and the messages will go away.

Like this?

diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 8fc7274..6b93d01 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -441,7 +441,7 @@ static int xircom_start_xmit(struct sk_buff *skb, struc=
t net_device *dev)
 	spin_unlock_irqrestore(&card->lock,flags);
 	trigger_transmit(card);
=20
-	return -EIO;
+	return NETDEV_TX_BUSY;
 }
=20
=20

It compiles without errors. I'm sorry I can't test it right now, I'm
100 km away from the machine and the same driver is used for both NICs
so if I goof up I won't be able to fix the it. I'll test it this friday
and let you know.


Erik

--=20
They're all fools. Don't worry. Darwin may be slow, but he'll
eventually get them. -- Matthew Lammers in alt.sysadmin.recovery

--48TaNjbzBVislYPb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHn56T/PlVHJtIto0RAt4OAJ9rmSoGdxp2364jnxChTl/ETelQvACfQ0+Y
MwpnicowXbCcogohkyh124M=
=briW
-----END PGP SIGNATURE-----

--48TaNjbzBVislYPb--
