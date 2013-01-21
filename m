From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 20:50:05 +0900
Message-ID: <50FD2B6D.9050803@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org> <50FCDF5D.3060300@gmail.com> <20130121083957.6e2c5a68@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephan.gatzka@gmail.com, netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:49992 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752403Ab3AULuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 06:50:11 -0500
In-Reply-To: <20130121083957.6e2c5a68@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013=E5=B9=B401=E6=9C=8821=E6=97=A5 16:39), Stefan Richter wrote:
> On Jan 21 Stephan Gatzka wrote:
>>> We could have multiple "net_device"s per single physical
>>> interface at the same time, then.
>>
>> Of course, but I would avoid it if it's not necessary. What's the=20
>> problem with introducing a function pointer in struct net_device or=20
>> struct net_device_ops?
>=20
> Two net_device instances on one 1394 card would be awkward:  They wou=
ld
> have to share one instance of isochronous reception context (for rece=
ption
> of asynchronous 1394 streams; those are used for broadcasts and
> multicasts).  Such a sharing is surely possible, but if double net_de=
vice
> instantiation can be avoided, then avoid it.
>=20
> Not to mention the user interface problem of having two netifs, one w=
hich
> only supports IPv4 and another one which only supports IPv6.  So far =
I
> never had IPv6 configured into a Linux kernel, but I suppose that fol=
ks
> are used to be able to use eth0 etc. for both protocols.
>=20
>>> Multicast is a big issue.  Because IPv6 is fan of
>>> multicast, and it uses link-local multicast as its
>>> core infrastructure.  Without infrastructure to
>>> support it, I'm not going to agree.
>>
>> firewire net supports multicast and we use it very often. My patch t=
o=20
>> support IPv6 does not change it. In fact, because I can communicate =
via=20
>> IPv6  between two firewire nodes, multicast _is_ running. The driver=
=20
>> does not do lot's of special things with multicast packets. But=20
>> multicast packets are recognized because they have to be sent someho=
w=20
>> different (GASP).
>=20
> (At the moment we transport multicasts to the same 1394 channel like
> broadcasts.
>=20
> IEEE 1394 supports two addressing modes:  IEEE 1212 based memory-mapa=
ble
> addresses of the form bus:node:offset =3D 10 bits + 6 bits + 48 bits =
for
> node-to-node communication, and "channel" =3D a 6 bit channel number =
for
> communication of 1 node to 0...n nodes.
>=20
> RFC 2734 broadcasts and multicasts use the channel addressing type.  =
Hence
> max_rec/ sspd/ unicast_FIFO come not into play with broadcasts and
> multicasts.  Broadcasts are sent to a fixed known channel number;
> multicasts are sent either to the broadcast channel number or to a
> separate channel number which is negotiated per multicast group using=
 RFC
> 2734 Multicast Channel Allocation Protocol.  For the time being the L=
inux
> driver only implements multicasts to the broadcast channel.)
>=20

Sending multicast without MCAP is okay,
but receiving multicast without MCAP is broken.
We have to be able to listen to NS (DAD) on separate
channel which is been negotiated over MCAP, for example.

--yoshfuji
