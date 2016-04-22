From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/3] ipgre: fix lwtunnel support
Date: Fri, 22 Apr 2016 19:44:05 +0200
Message-ID: <cover.1461346798.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932345AbcDVRoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 13:44:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lwtunnels currently work only with gretap. This patchset fixes the bugs in
ipgre metadata mode implementation.

As an example, in this setup:

ip a a 192.168.1.1/24 dev eth0
ip l a gre1 type gre external
ip l s gre1 up
ip a a 192.168.99.1/24 dev gre1
ip r a 192.168.99.2/32 encap ip dst 192.168.1.2 ttl 10 dev gre1
ping 192.168.99.2

the traffic does not go through before this patchset and does as expected
with it applied.

Jiri Benc (3):
  gre: do not assign header_ops in collect metadata mode
  gre: build header correctly for collect metadata tunnels
  gre: receive also TEB packets for lwtunnels

 include/net/ip_tunnels.h |  1 +
 net/ipv4/ip_gre.c        | 48 +++++++++++++++++++++++++++++++++---------------
 2 files changed, 34 insertions(+), 15 deletions(-)

-- 
1.8.3.1
