From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: TCP slowdown in 2.6.25?
Date: Mon, 28 Apr 2008 17:19:19 +0200
Message-ID: <1209395959.6904.25.camel@gentoo-jocke.transmode.se>
References: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
	 <1209389586.6904.17.camel@gentoo-jocke.transmode.se>
	 <Pine.LNX.4.64.0804281728280.1888@wrl-59.cs.helsinki.fi>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:46840 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933418AbYD1PTW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:19:22 -0400
In-Reply-To: <Pine.LNX.4.64.0804281728280.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-04-28 at 17:42 +0300, Ilpo J=E4rvinen wrote:
> On Mon, 28 Apr 2008, Joakim Tjernlund wrote:
> > On Mon, 2008-04-28 at 14:12 +0200, Joakim Tjernlund wrote:
> > > After upgrading from 2.6.23 to 2.6.25 I am seeing a big slow down=
 on
> > > our old www server. Stracing shows lots of EAGAIN but i not sure
> > > these are relevant. I got no idea where to start looking so
> > > I would appreciate some pointers. Perhaps this is a know issue?
> > >=20
> > > CPU is a PowerPC, mpc8321, network driver ucc_geth
> >=20
> > Some info:
> > Even ftp transfers takes forever, but only in one direction: from t=
he
> > node with kernel 2.6.25 to some other host. Strace show me that
> > write(2) hangs for long periods before succeeding to transmit=20
> > the data.
>=20
> Since it's easy, can you quickly try to if setting tcp_sack sysctl to=
 0=20
> makes any difference (I made a surgery there, perhaps some bug in the=
re=20
> could cause TCP to recover by RTO multiple times in a row, that shoul=
d=20
> be visible in tcpdump as well)?

echo 0 > /proc/sys/net/ipv4/tcp_sack
did not make a difference, same problem.


>=20
> Do you have network namespaces enabled in .config?

No,
# CONFIG_NAMESPACES is not set

>=20
> Netfilter/iptables involved?

Some support compiled into the kernel, but no one is using it.

>=20
> To some specific or "any" other host? How long is "long"?

Any host. A 1304632 bytes file takes about 110 seconds to transfer
(12 Kbytes/sec)

Thanks for helping.

A quick capture with wireshark indicates that some sent packages from
the node never reaches the host on the network.
