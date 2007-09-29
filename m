From: Laurent Riffard <laurent.riffard@free.fr>
Subject: Re: 2.6.23-rc[68]-mm: network hangs
Date: Sat, 29 Sep 2007 11:22:06 +0200
Message-ID: <46FE193E.60200@free.fr>
References: <46FD5A82.9070505@free.fr> <20070929013106.4f84320d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:50646 "EHLO smtp6-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824AbXI2JWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 05:22:09 -0400
In-Reply-To: <20070929013106.4f84320d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 29.09.2007 10:31, Andrew Morton a =E9crit :
> On Fri, 28 Sep 2007 21:48:18 +0200 Laurent Riffard <laurent.riffard@f=
ree.fr> wrote:
>=20
>> Hi,
>>
>> >From time to time, I experience some complete network hangs:
>>
>> Suddenly, all network connections become unresponsive. Even "ping
>> 127.0.0.1" doesn't work. SysRq-w does not show any blocked processus=
=2E
>>
>> When such hang happen, I have to reboot (shutdown does work).
>>
>> This is not easily reproducible: it happens several minutes after=20
>> boot (could be 45 minutes or 2 hours). I do not use heavy networking=
=20
>> apps (like P2P). My typical usage is a Gnome desktop with  browser,=20
>> mailer, IM, video or audio streaming.=20
>>
>> I have a single PC connected to a DSL router via ethernet (so no LAN=
=20
>> with NFS or CIFS).
>>
>> This happens with 2.6.23-rc8-mm2 and 2.6.23-rc6-mm1. I can't remembe=
r=20
>> when I first see this problem. Maybe 2 months ago.
>>
>> I attached the output of "strace ping 127.0.0.1". How can I collect=20
>> some more data when this problem happens ?
>>
>=20
> I have a second report of this from Uwe Bugla (who has been banished =
from
> all vger lists for various naughtinesses).
>=20
> Similar story - after a few hours his network router (which is using =
ppp in
> some fashion) craps out and dhcp queries all time out.
>=20
> I'd be suspecting a ppp bug in net-2.6.24.

mmm... I don't use PPP at all, nor dhcp.=20

My DSL box act as a NAT-router. Its local adress is 192.168.0.254 and m=
y PC=20
is at 192.192.0.9 (fixed IP).

       /--- telephone line=20
       |
 +----------+
 | ADSL box |
 +----------+
 192.168.0.254
       |
  192.168.0.9
 +-----------+
 |    PC     |
 +-----------+

=46irstly, I suspected a bug in the DSL box, so I reset it but it did n=
ot help.=20
I have to reboot the PC (don't need to reset the DSL box).=20

Could a router problem prevent "ping 127.0.0.1" from working ?

[this becomes somewhat off-topic for LKML, sorry]

Here's my routing table:

linux-2.6-mm$ LANG=3DC netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irt=
t Iface
192.168.0.0     0.0.0.0         255.255.255.0   U         0 0          =
0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U         0 0          =
0 eth0
0.0.0.0         192.168.0.254   0.0.0.0         UG        0 0          =
0 eth0

It seems it lacks a route for 127.0.0.1 through lo, isn't it? In this c=
ase, if=20
eth0 hangs, 127.0.0.1 hangs too, no?

So, it could be an ethernet driver bug. I'm using ne2k-pci.
--=20
laurent
