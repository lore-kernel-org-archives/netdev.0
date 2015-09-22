From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Tue, 22 Sep 2015 18:12:10 +0200
Message-ID: <cover.1442936392.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332AbbIVQMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 12:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the selling points of lwtunnel was the ability to specify the tunnel
destination using routes. However, this doesn't really work currently, as
ARP and ndisc replies are not handled correctly. ARP and ndisc replies won't
have tunnel metadata attached, thus they will be sent out with the default
parameters or not sent at all, either way never reaching the requester.

Most of the egress tunnel parameters can be inferred from the ingress
metada. The only and important exception is UDP ports. This patchset infers
the egress data from the ingress data and disallow settings of UDP ports in
tunnel routes. If there's a need for different UDP ports, a new interface
needs to be created for each port combination. Note that it's still possible
to specify the UDP ports to use, it just needs to be done while creating the
vxlan/geneve interface.

This covers only ARPs. IPv6 ndisc has the same problem but is harder to
solve, as there's already dst attached to outgoing skbs. Ideas to solve this
are welcome.

Jiri Benc (2):
  ipv4: send arp replies to the correct tunnel
  lwtunnel: remove source and destination UDP port config option

 include/net/ip_tunnels.h      |  2 ++
 include/uapi/linux/lwtunnel.h |  4 ----
 net/ipv4/arp.c                | 39 ++++++++++++++++++++------------
 net/ipv4/ip_tunnel_core.c     | 52 +++++++++++++++++++++++--------------------
 4 files changed, 55 insertions(+), 42 deletions(-)

-- 
1.8.3.1
