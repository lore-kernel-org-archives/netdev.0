From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Packets lost: Softirq
Date: Sat, 19 May 2007 21:28:23 +0200
Message-ID: <464F4FD7.80303@cosmosbay.com>
References: <3388.10.107.26.27.1179320821.squirrel@gpo.iitb.ac.in>    <464B19A9.700@freemail.hu> <2770.10.107.26.27.1179579009.squirrel@gpo.iitb.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vasantha Kumar Puttappa <vasanthakumar@iitb.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55982 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016AbXEST3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 15:29:10 -0400
In-Reply-To: <2770.10.107.26.27.1179579009.squirrel@gpo.iitb.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vasantha Kumar Puttappa a =E9crit :
> Hi All,
>  Please somebody guide me here. I desparatley need help regarding thi=
s
> issue. ( plz do "reply to all")
>=20
>  I am tracking all udp packets (in particular, SIP based UDP packets)=
that
> goes through the iptables using LOG mechanism.
>  I use the following command,
>      iptables -A INPUT -p udp -j LOG --log-level-4.
>      iptables -A FORWARD -p udp -j LOG --log-level-4
>=20
>   In addition, i also run 'Ethereal' to make sure that all the packet=
s
> captured goes through the iptables as well.
>=20
>   Here is the problem,
>     Sometimes, a random number of packets doesnot go through IPtables=
 and
>   they are completely lost. Although, I can see those lost packets in
> Ethereal. I tried increasing the backlog queue and ip_queue length, b=
ut
> still no use.
>=20
>    I am using Netgear's wireless network card (WG511, made in taiwan)=
=2E
>    Device driver: Prism54
>    firmware: isl3890
>    Kernel verison-- 2.6.11-6mdk
>=20
>   Let me give you more insight into what I am trying do.
>=20
>  I have a vitrual network interface and 2 physical network interface =
(one
> Ethernet based, and other 802.11 based). The virtual network interfac=
e
> dynamically binds to any one of the above physical interfaces for pac=
ket
> transmission. The issue of packet loss occurs **only** during link
> switching.
>=20
> I feel that the following issues might be the possible reasons for th=
e
> packet loss.
>=20
> 1. Due to missing soft_IRQ interrupt for packets and hence packet los=
s ( i
> have no proof to back this)
> 2. Due to incompatible wireless device driver.
>=20

netdev CCed

3) packets are going normally through iptables, but the '-j LOG' is flo=
oded=20
and syslog miss some of them.

Just do a : iptables -nvL INPUT

and check packets counters : they should match ethereal ones :)

-j LOG is not designed for logging all packets, just some of them :)

