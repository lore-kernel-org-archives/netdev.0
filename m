From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/3] gre: receive also TEB packets for lwtunnels
Date: Tue,  3 May 2016 17:10:05 +0200
Message-ID: <cover.1462286214.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, pravin shelar <pshelar@ovn.org>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635AbcECPKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 11:10:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NOTE: this patchset needs net merged to net-next.

This allows lwtunnel users to get also packets with ETH_P_TEB protocol
specified in GRE header through an ipgre interface. There's really nothing
special about these packets in the case of lwtunnels - it's just an inner
protocol like any other. The only complications stem from keeping
compatibility with other uses of GRE.

This will be used by openvswitch to support eth_push and eth_pop actions.
I'd also like to see tc support for lwtunnels (this feature included) in the
future.

The first patch is not directly related and can be submitted standalone if
needed.

Jiri Benc (3):
  gre: remove superfluous pskb_may_pull
  gre: move iptunnel_pull_header down to ipgre_rcv
  gre: receive also TEB packets for lwtunnels

 include/net/ip_tunnels.h |  1 +
 net/ipv4/gre_demux.c     |  5 +----
 net/ipv4/ip_gre.c        | 48 +++++++++++++++++++++++++++++++++++-------------
 3 files changed, 37 insertions(+), 17 deletions(-)

-- 
1.8.3.1
