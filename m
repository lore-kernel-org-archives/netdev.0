From: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>
Subject: IFF_PROMISC again
Date: Tue, 01 May 2007 15:36:08 -0300
Message-ID: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, for the nth time I send this email, hoping that majordomo won't eat
it again.


I know this has been extensibly discussed circa 2001, but I found that
there's still problems: in debian (at least) neither ifconfig nor ip
can tell that the interface is in promiscuous mode.

I know about the deprecation of IFF_PROMISC, but I couldn't find out
which is the current way of knowing the real state of the interface. I
want to fix ifconfig, so this is not an issue of
PACKET_(ADD|REMOVE)_MEMBERSHIP, I need to query the real device state.

Also, it's unclear to me what happens when you set/reset IFF_PROMISC
and then libpcap fiddles with membership. Is this documented
somewhere?

It has been said many times that ip should give this information. I
cannot see this:

$ sudo tcpdump -ni eth2 port 3333 &
$ dmesg |tail -2
device eth2 entered promiscuous mode
audit(1175904782.767:40): dev=3Deth2 prom=3D256 old_prom=3D0 auid=3D429=
4967295
$ ip link show eth2
4: eth2: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
1000
   link/ether 00:18:de:81:24:a2 brd ff:ff:ff:ff:ff:ff
$ ip -V
ip utility, iproute2-ss060323

I think that is a problem for user tools to not know about this, and I
want to fix them. I don't know how. Can anyone give me a pointer?

Thanks, Mart=C3=ADn.

--=20
Mart=C3=ADn Ferrari <martin.ferrari@gmail.com>

