From: Ken Moffat <zarniwhoop@ntlworld.com>
Subject: Re: Lost network connectivity in 4.0.x
Date: Thu, 28 May 2015 15:41:49 +0100
Message-ID: <20150528144149.GA29350@milliways>
References: <20150524024352.GA15747@milliways>
 <20150524032938.GA16664@milliways>
 <CAM_iQpXH_-WO8W=zVUaXezeGGOjFy-nBLy0k+tytZuMQqV1hcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpXH_-WO8W=zVUaXezeGGOjFy-nBLy0k+tytZuMQqV1hcQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 27, 2015 at 10:53:00PM -0700, Cong Wang wrote:
> (Please always Cc netdev for networking bugs.)
>=20
> On Sat, May 23, 2015 at 8:29 PM, Ken Moffat <zarniwhoop@ntlworld.com>=
 wrote:
> > On Sun, May 24, 2015 at 03:43:52AM +0100, Ken Moffat wrote:
> >> Anybody else suffering frm lost network connectivity in 4.0.x
> >> kernels ?  A couple of times this week, vim on an nfs-3 mount hung
> >> and I had to reboot.  Both of those occasions were on an AMD deskt=
op
> >> with the r8169 driver, running 4.0.3.  I thought it might be
> >> specific to that machine.  For the last two or three days I've bee=
n
> >> using an intel, and about 10 minutes ago it suffered the same prob=
lem
> >> while running 4.0.4.  Using ping from another term showed that it
> >> had no connectivity to the server on my local network.
> >>
> >> This is a bit hard to diagnose - nothing in the logs.
> >>
> > I forgot to add that this is with the released gcc-5.1 : I keep
> > forgetting that some people use old compilers ;-)
> >
>=20
> Is there any way you can help to narrow down the problem?
>=20

Thanks for the reply.  The problem is continuing to show up, but
irregularly and often only after the machine has been booted for a
long time (with s2ram, but I don't think I've used s2ram on every
occasion).

> For example:
>=20
> 1) What is your network setup? iptables? routes? etc.
>=20
I'm using iptables.  Ah, yes - it started dropping packets around
the time I last had a problem:

May 27 00:48:26 ac4tv dhclient: DHCPREQUEST on eth0 to 192.168.7.254
port 67
May 27 00:48:27 ac4tv dhclient: DHCPACK from 192.168.7.254
May 27 00:48:27 ac4tv dhclient: bound to 192.168.7.152 -- renewal in
1787 seconds.

 That address came from my router, and I had been getting the same
address for an hour, tbut then the dropped packet messages start
appearing - they are for a different address, one that would have
been offered by my server:

May 27 00:53:16 ac4tv kernel: [31922.316798] IPTABLES Packet
Dropped: IN=3Deth0 OUT=3D MAC=3Dc8:60:00:97:07:35:bc:ae:c5:57:70:c5:08:=
00
SRC=3D192.168.7.11 DST=3D192.168.7.121 LEN=3D60 TOS=3D0x00 PREC=3D0x00 =
TTL=3D64
ID=3D0 DF PROTO=3DTCP SPT=3D2049 DPT=3D1005 WINDOW=3D28960 RES=3D0x00 A=
CK SYN
URGP=3D0=20
May 27 00:53:17 ac4tv kernel: [31923.316612] IPTABLES Packet
Dropped: IN=3Deth0 OUT=3D MAC=3Dc8:60:00:97:07:35:bc:ae:c5:57:70:c5:08:=
00
SRC=3D192.168.7.11 DST=3D192.168.7.121 LEN=3D60 TOS=3D0x00 PREC=3D0x00 =
TTL=3D64
ID=3D0 DF PROTO=3DTCP SPT=3D2049 DPT=3D1005 WINDOW=3D28960 RES=3D0x00 A=
CK SYN
URGP=3D0=20

and those continued until I forced a reboot.

> 2) Can you check the stats to see if there is any error?
>   `ip -s -s li show`, `ethtool -S <DEV>`
>=20

I don't have ethtool installed, and that ip command appears ok at
the moment:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
mode DEFAULT group default=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast  =20
    3964       66       0       0       0       0      =20
    RX errors: length   crc     frame   fifo    missed
               0        0       0       0       0      =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    3964       66       0       0       0       0      =20
    TX errors: aborted  fifo   window heartbeat transns
               0        0       0       0       0      =20
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT group default qlen 1000
    link/ether c8:60:00:97:07:35 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast  =20
    224661061  277642   0       0       0       0      =20
    RX errors: length   crc     frame   fifo    missed
               0        0       0       0       0      =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    278152429  370438   0       0       0       0      =20
    TX errors: aborted  fifo   window heartbeat transns
               0        0       0       0       6      =20

> 3) Do a bisect?
>=20
> Thanks!

That doesn't seem very practical when the machine is ok for a couple
of days at a time.

=C4=B8en
--=20
Nanny Ogg usually went to bed early. After all, she was an old lady.
Sometimes she went to bed as early as 6 a.m.
