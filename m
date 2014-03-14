From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 11:05:25 +0200
Message-ID: <20140314090525.GB3200@reaktio.net>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
 <20140313202557.GV3200@reaktio.net>
 <1394746907.15946.8.camel@dcbw.local>
 <20140313220812.GW3200@reaktio.net>
 <20140314075548.GX3200@reaktio.net>
 <87wqfxnppc.fsf@nemi.mork.no>
 <20140314084159.GA3200@reaktio.net>
 <87siqlnol8.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh06.mail.saunalahti.fi ([62.142.5.116]:35308 "EHLO
	emh06.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601AbaCNJF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 05:05:28 -0400
Content-Disposition: inline
In-Reply-To: <87siqlnol8.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 09:58:43AM +0100, Bj=F8rn Mork wrote:
> Pasi K=E4rkk=E4inen <pasik@iki.fi> writes:
>=20
> > ^NDISSTAT:1,,,"IPV4"
> > ^RSSI: 21
> >
> > <I send: AT^DHCP?>
> > ^DHCP: CCDB080A,F8FFFFFF,C9DB080A,C9DB080A,E67B59C0,E77B59C0,85600,=
85600
>=20
>=20
> The hex numbers are IPv4 addresses in little endian. The decimal numb=
ers
> at the end are speed down/up IIRC.
>=20
> Printed in a more readable form, this is:
>=20
>  10.8.219.204,255.255.255.248,10.8.219.201,10.8.219.201,192.89.123.23=
0,192.89.123.231,85600,85600
>=20
> I believe this is to be interpreted as
>=20
>  yourip, netmask, gw, gw?, dns1, dns2
>=20
>=20
> Do stuff work if you manually configure the interface with the
> 10.8.219.204 address and set the default route to 10.8.219.201?
>=20

Unfortunately no :(=20

# ifconfig wwp0s26u1u5i1
wwp0s26u1u5i1: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.8.219.204  netmask 255.255.255.248  broadcast 10.8.219.=
207
        inet6 fe80::e5b:8fff:fe27:9a64  prefixlen 64  scopeid 0x20<link=
>
        ether 0c:5b:8f:27:9a:64  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 1493  dropped 0  overruns 0  frame 0

Note the RX errors.. ?=20

        TX packets 53  bytes 532885 (520.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use=
 Iface
0.0.0.0         10.8.219.201    0.0.0.0         UG    0      0        0=
 wwp0s26u1u5i1
10.8.219.200    0.0.0.0         255.255.255.248 U     0      0        0=
 wwp0s26u1u5i1


# ping 10.8.219.201
PING 10.8.219.201 (10.8.219.201) 56(84) bytes of data.
=46rom 10.8.219.204 icmp_seq=3D1 Destination Host Unreachable
=46rom 10.8.219.204 icmp_seq=3D2 Destination Host Unreachable
=46rom 10.8.219.204 icmp_seq=3D3 Destination Host Unreachable
=46rom 10.8.219.204 icmp_seq=3D4 Destination Host Unreachable


And pinging anywhere else doesn't work either.. (I also tried telnet/ss=
h/web - doesn't work).

More ideas?=20


> This is one way to rewrite the addresses if you need to for a new
> connection:
>=20
>  perl -e 'print join(".", reverse map {hex} unpack("(A2)*", shift)),"=
\n"' C9DB080A
>=20

This is handy, thanks!

>=20
>=20
> Bj=F8rn
>=20



-- Pasi
