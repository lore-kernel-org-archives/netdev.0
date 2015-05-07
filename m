From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmenation icmp v2 0/2] fragmentation ICMP
Date: Wed,  6 May 2015 18:27:11 -0700
Message-ID: <1430962033-16141-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:44159 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750824AbbEGBtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 21:49:00 -0400
Received: by mail-pd0-f178.google.com with SMTP id a3so26167642pde.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 18:48:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we send ICMP packets when errors occur during fragmentation or
de-fragmentation.  However, it is a bug when sending those ICMP packets
in the context of using netfilter for bridging.

Those ICMP packets are only expected in the context of routing, not in
bridging mode.

The Local stack are not involved in bridging forward decisions, thus
should be not used for deciding the reverse path for those ICMP messages.

This bug only affects IPV4, not in IPv6.

---
v1->v2:  restructure the patches into two patches that fix defragmentation and
         fragmentation respectively. 

	 A bit is add in IPCB to control whether ICMP packet should be
	 generated for defragmentation.

	 Fragmentation ICMP is now removed by restructuring the
	 ip_fragment() API.

Andy Zhou (2):
  bridge_netfilter: No ICMP packet on IPv4 defragmentation timeout
  bridge_netfilter: No ICMP packet on IPv4 fragmentation error

 include/net/inet_frag.h   |  4 +++-
 include/net/ip.h          |  3 +++
 net/bridge/br_netfilter.c | 25 ++++++++++++++++++++++++-
 net/ipv4/ip_fragment.c    | 12 ++++++++++--
 net/ipv4/ip_output.c      | 36 ++++++++++++++++++++++++------------
 5 files changed, 64 insertions(+), 16 deletions(-)

-- 
1.9.1
