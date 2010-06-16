From: Christian Casteyde <casteyde.christian@free.fr>
Subject: Re: [Bugme-new] [Bug 16187] New: Carrier detection failed in dhcpcd when link is up
Date: Wed, 16 Jun 2010 07:46:23 +0200
Message-ID: <201006160746.23417.casteyde.christian@free.fr>
References: <bug-16187-10286@https.bugzilla.kernel.org/> <20100615142418.f47e8abd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:39268 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357Ab0FPFnB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 01:43:01 -0400
In-Reply-To: <20100615142418.f47e8abd.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exact, my kernel config is:
-*- Generic Media Independent Interface device support
[*]   "Tulip" family network device support
<*>   ULi M526x controller support

Le mardi 15 juin 2010 23:24:18, Andrew Morton a =E9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Sat, 12 Jun 2010 15:15:31 GMT
>=20
> bugzilla-daemon@bugzilla.kernel.org wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D16187
> >=20
> >            Summary: Carrier detection failed in dhcpcd when link is=
 up
> >            Product: Networking
> >            Version: 2.5
> >    =20
> >     Kernel Version: 2.6.35-rc2
> >    =20
> >           Platform: All
> >        =20
> >         OS/Version: Linux
> >        =20
> >               Tree: Mainline
> >            =20
> >             Status: NEW
> >          =20
> >           Severity: normal
> >           Priority: P1
> >         =20
> >          Component: Other
> >        =20
> >         AssignedTo: acme@ghostprotocols.net
> >         ReportedBy: casteyde.christian@free.fr
> >         Regression: Yes
> >=20
> > Created an attachment (id=3D26742)
> >=20
> >  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D26742)
> >=20
> > lspci output for 2.6.34 on my computer
> >=20
> > Kernel at least 2.6.35-rc2, 2.6.34 works fine
>=20
> Seems to be post-2.6.34 breakage in the tulip driver.
>=20
> > Athlon X2 3000 in 64bits mode
> > Slackware 13.1
> > "Ethernet controller: ALi Corporation ULi 1689,1573 integrated ethe=
rnet.
> > (rev 40)" (from lspci)
> >=20
> > Since 2.6.35-rc2 (didn't checked -rc1), dhcpcd hangs fails to detec=
t
> > carrier appearance at boot.
> >=20
> > The Slackware network script uses dhcpcd to bring DHCP interfaces u=
p. At
> > boot, it seems my network device doesn't have the link up immediatl=
y.
> > dhcpcd tries to bring it up, and wait for the carrier. The carrier
> > indeed goes up, but dhcpcd gets absolutly no notification of that, =
and
> > therefore times out.
> >=20
> > logs says that:
> > Jun 12 16:53:58 sirius logger: /etc/rc.d/rc.inet1:  /sbin/route add=
 -net
> > 127.0.0.0 netmask 255.0.0.0 lo
> > Jun 12 16:53:58 sirius logger: /etc/rc.d/rc.inet1:  /sbin/dhcpcd -t=
 10=20
> > eth0 Jun 12 16:53:58 sirius dhcpcd: version 5.2.2 starting
> > Jun 12 16:53:58 sirius kernel: ADDRCONF(NETDEV_UP): eth0: link is n=
ot
> > ready Jun 12 16:53:58 sirius dhcpcd: eth0: waiting for carrier
> > Jun 12 16:54:01 sirius kernel: uli526x: eth0 NIC Link is Up 100 Mbp=
s Full
> > duplex
> > Jun 12 16:54:01 sirius kernel: ADDRCONF(NETDEV_CHANGE): eth0: link
> > becomes ready
> > then dhcpcd times out a little later (10 seconds as -t 10 is specif=
ied).
> >=20
> > If I use the -K option (no carrier detection), and does ifconfig et=
h0 up
> > just before issueing the dhcpcd command, dhcpcd doesn't wait for th=
e
> > carrier and gets a lease correctly.
> >=20
> > Reversely, with the 2.6.34 kernel, dhcpcd indeed gets the link up
> > notification, and gets the lease immediatly. In this case, the log =
says:
> >=20
> > Jun 12 17:04:21 sirius logger: /etc/rc.d/rc.inet1:  /sbin/route add=
 -net
> > 127.0.0.0 netmask 255.0.0.0 lo
> > Jun 12 17:04:21 sirius logger: /etc/rc.d/rc.inet1:  /sbin/dhcpcd -t=
 10=20
> > eth0 Jun 12 17:04:22 sirius dhcpcd: version 5.2.2 starting
> > Jun 12 17:04:22 sirius kernel: ADDRCONF(NETDEV_UP): eth0: link is n=
ot
> > ready Jun 12 17:04:22 sirius dhcpcd: eth0: waiting for carrier
> > Jun 12 17:04:25 sirius dhcpcd: eth0: carrier acquired
> > Jun 12 17:04:25 sirius kernel: uli526x: eth0 NIC Link is Up 100 Mbp=
s Full
> > duplex
> > Jun 12 17:04:25 sirius kernel: ADDRCONF(NETDEV_CHANGE): eth0: link
> > becomes ready
> > Jun 12 17:04:25 sirius dhcpcd: eth0: broadcasting for a lease
> > Jun 12 17:04:29 sirius dhcpcd: eth0: offered 192.168.1.3 from 192.1=
68.1.1
> > Jun 12 17:04:29 sirius dhcpcd: eth0: acknowledged 192.168.1.3 from
> > 192.168.1.1 Jun 12 17:04:29 sirius dhcpcd: eth0: checking for
> > 192.168.1.3
> > Jun 12 17:04:34 sirius dhcpcd: eth0: leased 192.168.1.3 for 864000
> > seconds Jun 12 17:04:34 sirius dhcpcd: forking to background
> >=20
> > As you can see, dhcpcd asks for a lease as soon as the kernel tells=
 it
> > the link is up (message "carrier acquired").
> >=20
> > Therefore, I think 2.6.35-rc* notification of carrier is broken, an=
d at
> > least it broke dhcpcd way of watching the link.
