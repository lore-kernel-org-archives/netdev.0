From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 still badly broken
Date: Thu, 3 May 2012 11:15:36 -0700
Message-ID: <20120503111536.269490e3@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
	<4FA14EC6.6050207@linuxsystems.it>
	<20120502115618.04ab8ff9@s6510.linuxnetplumber.net>
	<4FA2527A.6020808@linuxsystems.it>
	<20120503082352.771acab3@nehalam.linuxnetplumber.net>
	<4FA2C913.4080504@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38557 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab2ECSPk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 14:15:40 -0400
In-Reply-To: <4FA2C913.4080504@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 May 2012 20:06:11 +0200
Niccol=F2 Belli <darkbasic@linuxsystems.it> wrote:

> Il 03/05/2012 17:23, Stephen Hemminger ha scritto:
> > The receiver on some versions of the chip can't keep up with full s=
peed
> > of 1G bit/sec. The receive  FIFO has hardware issues, and since I d=
on't
> > work for Marvell, working around the problem is guesswork. Without =
exact
> > information all that can be done is have a timeout and blunt force =
reset
> > logic. The vendor driver sk98lin has the same brute force logic, bu=
t may
> > just not print the message.
>=20
> If I lower the speed to 100Mb/s I don't have rx errors anymore *BUT*=20
> when using dhcp after a while the network doesn't work anymore:
>=20
> 64 bytes from 8.8.8.8: icmp_req=3D590 ttl=3D47 time=3D61.7 ms
> 64 bytes from 8.8.8.8: icmp_req=3D591 ttl=3D47 time=3D62.0 ms
> 64 bytes from 8.8.8.8: icmp_req=3D592 ttl=3D47 time=3D62.0 ms
> ping: sendmsg: Network is unreachable
> ping: sendmsg: Network is unreachable
> ping: sendmsg: Network is unreachable
>=20
>=20
> I have no problems with dhcp using wifi or other NICs.
>=20
> Niccol=F2

Maybe ethtool registers have some info?

# ethtool -S eth0
NIC statistics:
     tx_bytes: 3640274
     rx_bytes: 61588953
     tx_broadcast: 641
     rx_broadcast: 9964
     tx_multicast: 126
     rx_multicast: 1501
     tx_unicast: 32683
     rx_unicast: 50415
     tx_mac_pause: 0
     rx_mac_pause: 0
     collisions: 0
     late_collision: 0
     aborted: 0
     single_collisions: 0
     multi_collisions: 0
     rx_short: 0
     rx_runt: 0
     rx_64_byte_packets: 8704
     rx_65_to_127_byte_packets: 4414
     rx_128_to_255_byte_packets: 6218
     rx_256_to_511_byte_packets: 1289
     rx_512_to_1023_byte_packets: 1777
     rx_1024_to_1518_byte_packets: 39478
     rx_1518_to_max_byte_packets: 0
     rx_too_long: 0
     rx_fifo_overflow: 0
     rx_jabber: 0
     rx_fcs_error: 0
     tx_64_byte_packets: 1628
     tx_65_to_127_byte_packets: 27483
     tx_128_to_255_byte_packets: 2885
     tx_256_to_511_byte_packets: 637
     tx_512_to_1023_byte_packets: 429
     tx_1024_to_1518_byte_packets: 388
     tx_1519_to_max_byte_packets: 0
     tx_fifo_underrun: 0


And if you enable the debugfs option there is more info
hidden there.

# mount -t debugfs debugfs /sys/kernel/debug
# cat /sys/kernel/debug/sky2/eth0
