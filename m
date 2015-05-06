From: Andy Zhou <azhou@nicira.com>
Subject: [fragmentation ICMP 0/2] fragmentation ICMP
Date: Tue,  5 May 2015 18:59:52 -0700
Message-ID: <1430877594-32054-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:38627 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752830AbbEFC2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 22:28:46 -0400
Received: by mail-pa0-f53.google.com with SMTP id tp1so213002062pab.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 19:28:45 -0700 (PDT)
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

This patch series adds a bit in IPCB to control whether ICMP packet
should be generated on fragmentation or de-fragmentation error. Currently
the only user is br_netfilter.

Andy Zhou (2):
  ipv4_fragment: Add a bit in IPCB to control ICMP generation
  bridge: do not send icmp on fragmentation or defragmentation error

 include/net/inet_frag.h   |  2 ++
 include/net/ip.h          |  1 +
 net/bridge/br_netfilter.c |  7 +++++++
 net/ipv4/ip_fragment.c    | 11 ++++++++++-
 net/ipv4/ip_output.c      |  5 +++--
 5 files changed, 23 insertions(+), 3 deletions(-)

-- 
1.9.1

*** BLURB HERE ***

Andy Zhou (2):
  ipv4_fragment: Add a bit in IPCB to control ICMP generation
  bridge: do not send icmp on fragmentation or defragmentation error

 include/net/inet_frag.h   |  2 ++
 include/net/ip.h          |  1 +
 net/bridge/br_netfilter.c |  7 +++++++
 net/ipv4/ip_fragment.c    | 11 ++++++++++-
 net/ipv4/ip_output.c      |  5 +++--
 5 files changed, 23 insertions(+), 3 deletions(-)

-- 
1.9.1
