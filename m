From: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Subject: IP forwarding on a linux IPSec gateway
Date: Fri, 27 Jan 2012 15:31:49 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2059F2B32@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-1.cisco.com ([72.163.197.25]:37396 "EHLO
	bgl-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab2A0KBw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 05:01:52 -0500
Received: from xbh-bgl-411.cisco.com (xbh-bgl-411.cisco.com [72.163.129.201])
	by bgl-core-3.cisco.com (8.14.3/8.14.3) with ESMTP id q0RA1oEG010820
	for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 10:01:50 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to establish an IPSec tunnel to protect a subnet behind a l=
inux machine and a subnet behind some other gateway.
Lefsubnet - 172.17.0.0/16 (behind linux gateway)
Rightsubnet - 172.16.0.0/16

=46rom a host on left subnet, I am trying to ping to a host on right su=
bnet-
ping 172.16.60.1 -I 172.17.70.87

tcpdump capture on linux machine connected to left subnet-
04:27:09.939598 IP 172.17.70.87 > 172.16.60.1: icmp 64: echo request se=
q 170

Tcpdump capture on linux machine connected on right subnet-
04:26:32.941624 IP 1.1.0.1 > 192.168.101.101: ESP(spi=3D0x020000c3,seq=3D=
0x16d)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 //Outer IPs
04:26:32.943940 IP 192.168.101.101 > 1.1.0.1: ESP(spi=3D0x10000102,seq=3D=
0x16d)
04:26:32.943940 IP 172.16.60.1 > 172.17.70.87: icmp 64: echo reply seq =
133

So, it's clear that linux gateway is able to protect the data and send =
to the connected gateway (ESP packets to outer IPs).
And the second gateway is responding with ESP packet which is decoded o=
n linux gateway and sent to the ip stack again by linux kernel (ICMP re=
ply).
But the reply doesn't reach the host on left subnet.

I enabled ip_forwarding through /proc/sys/net/ipv4/ip_forwarding.

Please let me know, if I am missing something.

Any help would be appreciated.

Regards,
Prashant
