From: Marco Berizzi <pupilla@hotmail.com>
Subject: =?windows-1256?Q?ipsec_and_?= =?windows-1256?Q?snat:_mtu_?=
 =?windows-1256?Q?question=FE?=
Date: Thu, 28 Jun 2012 15:08:00 +0200
Message-ID: <DUB108-W166133D2C5FF7B74EDED00B2E60@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1256
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s22.dub0.hotmail.com ([157.55.0.221]:25125 "EHLO
	dub0-omc1-s22.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753111Ab2F1NIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 09:08:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hello everybody.
=A0
Kindly, I would like to ask for explanations
about a linux ipsec gateway snatting packets.
=A0
Here is the network schema.
=A0
customer private network 10.16.0.0/16
|
|
+ipsec customer gateway (checkpoint)
||
||---ipsec tunnel 10.16.0.0/16<->172.16.128.0/28 (des3/md5)
||=A0=A0 mtu=3D1446
||
++ linux_gw_snat ipsec gateway (SNAT all packets from 172.22.1.0/24 to =
172.16.128.1)
||=20
||---ipsec tunnel 10.16.0.0/16<->172.22.1.0/24 (aes/sha1/ipcomp)
||=A0=A0 mtu=3D1430
||
+linux_final ipsec gateway
|
|
client 172.22.1.50
=A0
SYN packet start behind the linux_final (172.22.1.50)
for 10.16.237.66 customer network. MSS is 1460 byte.
DF flag is set on outgoing packets.
Packet travel inside the ipsec tunnel: tunnel mtu is
1430
At the linux_gw_snat, the packet get decryped, snatted
(ip src change from 172.22.1.50 to 172.16.128.1) and
encryped again.
Packets are delivered to the checkpoint: tunnel mtu is
1446
Checkpoint deliver the decryped packet to 10.16.237.66
So far, so good.
=A0
At some point, 10.16.237.66 will send a 1500 byte
packet for 172.16.128.1: checkpoint will reply with
an icmp packet too large need to frag: mtu is 1446
=A0
10.16.237.66 will send back a 1446 byte packet to
the checkpoint which will encrypt and deliver to the
linux_gw_snat which will decrypt and deSNAT. Now
linux_gw_snat must send this 1446 byte packet to
172.22.1.50 but mtu is only 1430: packet will be
dropped (DF is set).
=A0
Now, IMHO, linux_gw_snat should send an imcp message
to 10.16.237.66 telling that max mtu is 1430, but I
don't see any icmp packet.
Is this the expected behaviour?
=A0
TIA
=A0
PS: linux_gw_snat is 3.3.5
 		 	   		 =20
