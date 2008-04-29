From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: TCP slowdown in 2.6.25?
Date: Tue, 29 Apr 2008 12:51:24 +0200
Message-ID: <1209466284.6904.36.camel@gentoo-jocke.transmode.se>
References: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
	 <1209389586.6904.17.camel@gentoo-jocke.transmode.se>
	 <Pine.LNX.4.64.0804281728280.1888@wrl-59.cs.helsinki.fi>
	 <1209395959.6904.25.camel@gentoo-jocke.transmode.se>
	 <Pine.LNX.4.64.0804281826260.1888@wrl-59.cs.helsinki.fi>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:16028 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753711AbYD2Kv0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:51:26 -0400
In-Reply-To: <Pine.LNX.4.64.0804281826260.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-04-28 at 18:48 +0300, Ilpo J=E4rvinen wrote:
> On Mon, 28 Apr 2008, Joakim Tjernlund wrote:
>=20
> > On Mon, 2008-04-28 at 17:42 +0300, Ilpo J=E4rvinen wrote:
> > > On Mon, 28 Apr 2008, Joakim Tjernlund wrote:
> > > > On Mon, 2008-04-28 at 14:12 +0200, Joakim Tjernlund wrote:
> > > > > After upgrading from 2.6.23 to 2.6.25 I am seeing a big slow =
down on
> > > > > our old www server. Stracing shows lots of EAGAIN but i not s=
ure
> > > > > these are relevant. I got no idea where to start looking so
> > > > > I would appreciate some pointers. Perhaps this is a know issu=
e?
> > > > >=20
> > > > > CPU is a PowerPC, mpc8321, network driver ucc_geth
> > > >=20
> > > > Some info:
> > > > Even ftp transfers takes forever, but only in one direction: fr=
om the
> > > > node with kernel 2.6.25 to some other host. Strace show me that
> > > > write(2) hangs for long periods before succeeding to transmit=20
> > > > the data.
>=20
> > > To some specific or "any" other host? How long is "long"?
> >=20
> > Any host. A 1304632 bytes file takes about 110 seconds to transfer
> > (12 Kbytes/sec)
> >
> > A quick capture with wireshark indicates that some sent packages fr=
om
> > the node never reaches the host on the network.
>=20
> Thanks, this is the important bit of info, TCP flow control limit see=
ms=20
> just a consequence of that... ...Now we'll just have to figure out wh=
at is=20
> causing those losses.
>=20
> Is there some middlebox on the route to that host?

Problem solved, was a bug in the ucc_geth driver. See the patch I just
sent. Thanks for your help.

 Jocke
