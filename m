From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: sky2 still badly broken
Date: Wed, 02 May 2012 17:12:06 +0200
Message-ID: <4FA14EC6.6050207@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:42451 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391Ab2EBPLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 11:11:05 -0400
In-Reply-To: <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 30/04/2012 21:25, Stephen Hemminger ha scritto:
> You are getting CRC and FIFO overrun errors. What laptop is this?
> Everything works fine on my old Fuijitsu with same chip (but rev 14).
> You could try taking out the status bit checks and see if the
> packets are really okay and the Marvell chip is complaining about
> bogus status.

I compiled 3.4-rc5 + both sky2 patches you recently published and I did=
=20
some more tests:

Point to point: works flawlessly.
Attached to the switch: rx errors, even downloading a very small 89 KB=20
file :(

This is the dump using IPv4:
http://files.linuxsystems.it/temp/2012-05/sky2_ipv4.pcap

dmesg (I did an rmmod -f sky2 before doing the test):
[ 1147.885026] sky2 0000:06:00.0: eth0: disabling interface
[ 1148.909548] sky2: driver version 1.30
[ 1148.909764] sky2 0000:06:00.0: Yukon-2 EC Ultra chip revision 3
[ 1148.914367] sky2 0000:06:00.0: irq 45 for MSI/MSI-X
[ 1148.916310] sky2 0000:06:00.0: eth0: addr 00:13:77:b4:1b:fa
[ 1148.942297] sky2 0000:06:00.0: eth0: enabling interface
[ 1148.944225] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 1151.496295] sky2 0000:06:00.0: eth0: Link is up at 1000 Mbps, full=20
duplex, flow control rx
[ 1151.497614] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[ 1178.479437] device eth0 entered promiscuous mode
[ 1179.541707] *sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
length 1468*
[ 1179.544110] *sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
length 1468*
[ 1181.642598] device eth0 left promiscuous mode




This is the dump using IPv6:
http://files.linuxsystems.it/temp/2012-05/sky2_ipv6.pcap

dmesg (I did an rmmod -f sky2 before doing the test):
[ 1314.225572] sky2 0000:06:00.0: eth0: disabling interface
[ 1315.248523] sky2: driver version 1.30
[ 1315.248731] sky2 0000:06:00.0: Yukon-2 EC Ultra chip revision 3
[ 1315.249333] sky2 0000:06:00.0: irq 45 for MSI/MSI-X
[ 1315.250307] sky2 0000:06:00.0: eth0: addr 00:13:77:b4:1b:fa
[ 1315.271364] sky2 0000:06:00.0: eth0: enabling interface
[ 1315.273015] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 1317.875985] sky2 0000:06:00.0: eth0: Link is up at 1000 Mbps, full=20
duplex, flow control rx
[ 1317.877311] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[ 1345.946062] device eth0 entered promiscuous mode
[ 1349.119848] device eth0 left promiscuous mode
[ 1376.231698] device eth0 entered promiscuous mode
[ 1377.369095] *sky2 0000:06:00.0: eth0: rx error, status 0x7ffc0001=20
length 1468*
[ 1379.618257] device eth0 left promiscuous mode



Switch is a Netgear GS724Tv3 firmware 5.0.3.5


Cheers,
Niccol=F2
