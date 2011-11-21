From: Albert Chin <linux-netdev@mlists.thewrittenword.com>
Subject: Re: Problems with dropped packets on bonded interface for 3.x
 kernels
Date: Mon, 21 Nov 2011 01:44:54 -0600
Message-ID: <20111121074453.GA7596@china>
References: <20111121051603.GB3702@china>
 <1321857123.17419.2.camel@edumazet-laptop>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.thewrittenword.com ([69.67.212.77]:51053 "EHLO
	mail1.thewrittenword.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab1KUHoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 02:44:55 -0500
Received: from mail1.il.thewrittenword.com (emma-internal-gw.il.thewrittenword.com [192.168.13.25])
	by mail1.thewrittenword.com (Postfix) with ESMTP id D8A2D5C09
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 08:19:57 +0000 (UTC)
Received: from china.thewrittenword.com (danger-gw.il.thewrittenword.com [10.191.57.254])
	by mail1.il.thewrittenword.com (Postfix) with ESMTP id 063BF6F5
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 07:44:55 +0000 (UTC)
Content-Disposition: inline
In-Reply-To: <1321857123.17419.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 07:32:03AM +0100, Eric Dumazet wrote:
> Le dimanche 20 novembre 2011 =E0 23:16 -0600, Albert Chin a =E9crit :
> > I'm running Ubuntu 11.10 on an Intel SR2625URLXR system with an Int=
el
> > S5520UR motherboard and an internal Intel E1G44HT (I340-T4) Quad Po=
rt
> > Server Adapter. I am seeing dropped packets on a bonded interface,
> > comprised of two GigE ports on the Intel E1G44HT Quad Port Server
> > Adapter. The following kernels exhibit this problem:
> >   3.0.0-12-server, 3.0.0-13-server, 3.1.0-2-server, 3.2.0-rc2
> > Installing Fedora 16 with a 3.1.1-1.fc16.x86_64 also showed dropped
> > packets.
> >=20
> > I also tried RHEL6 with a 2.6.32-131.17.1.el6.x86_64 kernel and did=
n't
> > see any dropped packets. Testing an older 2.6.32-28.55-generic Ubun=
tu
> > kernel also didn't show any dropped packets.
> >=20
> > So, with 2.6, I don't see dropped packets, but everything including
> > 3.0 and after show dropped packets.
> >=20
> > # ifconfig bond0
> > bond0     Link encap:Ethernet  HWaddr 00:1b:21:d3:f6:0a =20
> >           inet6 addr: fe80::21b:21ff:fed3:f60a/64 Scope:Link
> >           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
> >           RX packets:225 errors:0 dropped:186 overruns:0 frame:0
> >           TX packets:231 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:0=20
> >           RX bytes:25450 (25.4 KB)  TX bytes:28368 (28.3 KB)
> >=20
> > [[ snip snip ]]
>=20
> Old kernels were dropping some packets (unknown protocols...) without
> counting them.
>=20
> So following patch was added in 2.6.37 :
>=20
> You could use tcdpump to identify what are these dropped packets :)

So only "unknown" protocols are dropped? I just ran tcpdump for 96
packets and inspected the output. The only packets received are LACP,
ARP, STP (Spanning Tree Protocol), DTP (Dynamic Trunking Protocol).
How are these "unknown"?

> commit caf586e5f23cebb2a68cbaf288d59dbbf2d74052
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Thu Sep 30 21:06:55 2010 +0000
>=20
>     net: add a core netdev->rx_dropped counter
>    =20
>     In various situations, a device provides a packet to our stack an=
d we
>     drop it before it enters protocol stack :
>     - softnet backlog full (accounted in /proc/net/softnet_stat)
>     - bad vlan tag (not accounted)
>     - unknown/unregistered protocol (not accounted)
>    =20
>     We can handle a per-device counter of such dropped frames at core=
 level,
>     and automatically adds it to the device provided stats (rx_droppe=
d), so
>     that standard tools can be used (ifconfig, ip link, cat /proc/net=
/dev)
>    =20
>     This is a generalization of commit 8990f468a (net: rx_dropped
>     accounting), thus reverting it.
>    =20
>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

--=20
albert chin (china@thewrittenword.com)
