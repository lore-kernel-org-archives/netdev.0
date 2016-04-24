From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v2 0/3] gre: fix lwtunnel support
Date: Sun, 24 Apr 2016 13:00:19 +0200
Message-ID: <cover.1461495411.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbcDXLAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 07:00:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes a few bugs in gre metadata mode implementation, mainly
with ipgre.

As an example, in this setup:

ip a a 192.168.1.1/24 dev eth0
ip l a gre1 type gre external
ip l s gre1 up
ip a a 192.168.99.1/24 dev gre1
ip r a 192.168.99.2/32 encap ip dst 192.168.1.2 ttl 10 dev gre1
ping 192.168.99.2

the traffic does not go through before this patchset and does as expected
with it applied.

v2: Rejecting invalid configuration, added patch 3, dropped patch for
    ETH_P_TEB (will target net-next).

Jiri Benc (3):
  gre: do not assign header_ops in collect metadata mode
  gre: build header correctly for collect metadata tunnels
  gre: allow creation of gretap interfaces in metadata mode

 net/ipv4/ip_gre.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

-- 
1.8.3.1
