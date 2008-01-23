From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: arp queries and ipsec policy
Date: Wed, 23 Jan 2008 21:37:22 +0100
Message-ID: <BAY103-DAV10E05A9F06E3B3ED6C10A0B23F0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s7.bay0.hotmail.com ([65.54.246.79]:13633 "EHLO
	bay0-omc1-s7.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751512AbYAWUbO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 15:31:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody.
I'm using openswan 2.4.x to drive the linux 2.4.23.14 ipsec
native stack (netkey).
Openswan by default insert a static route when an ipsec SA
is established: this is needed by the klips stack as it is
routing based. For example when a roadwarrior establish
an ipsec SA with the linux box I see a static route like
this:

# ip r s
road_warrior_public_ip dev eth0  scope link

This static route is placed by the default updown script.
When there is this route, I see linux doing arp queries for
the road_warrior_public_ip:

# tcpdump -pnvi eth0 arp
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
17:25:11.608179 arp who-has road_warrior_public_ip tell linux_public_ip_address
17:25:12.608171 arp who-has road_warrior_public_ip tell linux_public_ip_address
17:25:13.608224 arp who-has road_warrior_public_ip tell linux_public_ip_address

Is this behaviour expected?

I have seen this behaviour today because the ISP router
isn't configured with proxy_arp and linux is unable to
send the ESP packets because the is no arp reply from nobody.
However it is able to receive/decrypt them:

# tcpdump -pnvi eth0 ip host road_warrior_public_ip
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes

17:24:55.107497 IP (tos 0x0, ttl 120, id 55048, offset 0, flags [none], proto:
ESP (50), length: 112) road_warrior_public_ip > linux_public_ip_address:
ESP(spi=0xe215d75f,seq=0x25), length 92

17:24:55.109304 IP (tos 0x0, ttl 128, id 2262, offset 0, flags [none], proto:
ICMP (1), length: 60) road_warrior_public_ip > 172.25.5.4: ICMP echo request,
id 512, seq 50694, length 40

I have resolved the problem modifying the updown script so
it doesn't place the static route anymore.

PS: default parameters for eth0 on /proc except proxy_arp,
arp_announce and rp_filter
