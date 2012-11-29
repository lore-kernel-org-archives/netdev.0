From: Jesse Gross <jesse@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Thu, 29 Nov 2012 10:35:42 -0800
Message-ID: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:34565 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751100Ab2K2Sf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:35:56 -0500
Received: by mail-pa0-f70.google.com with SMTP id hz11so15481772pad.1
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:35:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of improvements for 3.8/net-next contains four components:
 * Support for modifying IPv6 headers
 * Support for matching and setting skb->mark for better integration with
   things like iptables
 * Ability to recognize the EtherType for RARP packets
 * Two small performance enhancements

The movement of ipv6_find_hdr() into exthdrs_core.c causes two small merge
conflicts.  I left it as is but can do the merge if you want.  The conflicts
are:
 * ipv6_find_hdr() and ipv6_find_tlv() were both moved to the bottom of
   exthdrs_core.c.  Both should stay.
 * A new use of ipv6_find_hdr() was added to net/netfilter/ipvs/ip_vs_core.c
   after this patch.  The IPVS user has two instances of the old constant
   name IP6T_FH_F_FRAG which has been renamed to IP6_FH_F_FRAG.

The following changes since commit d04d382980c86bdee9960c3eb157a73f8ed230cc:

  openvswitch: Store flow key len if ARP opcode is not request or reply. (2012-10-30 17:17:09 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 92eb1d477145b2e7780b5002e856f70b8c3d74da:

  openvswitch: Use RCU callback when detaching netdevices. (2012-11-28 14:04:34 -0800)

----------------------------------------------------------------
Ansis Atteka (3):
      ipv6: improve ipv6_find_hdr() to skip empty routing headers
      openvswitch: add ipv6 'set' action
      openvswitch: add skb mark matching and set action

Jesse Gross (2):
      ipv6: Move ipv6_find_hdr() out of Netfilter code.
      openvswitch: Use RCU callback when detaching netdevices.

Mehak Mahajan (1):
      openvswitch: Process RARP packets with ethertype 0x8035 similar to ARP packets.

Shan Wei (1):
      net: openvswitch: use this_cpu_ptr per-cpu helper

 include/linux/netfilter_ipv6/ip6_tables.h |    9 ---
 include/linux/openvswitch.h               |    1 +
 include/net/ipv6.h                        |   10 +++
 net/ipv6/exthdrs_core.c                   |  123 +++++++++++++++++++++++++++++
 net/ipv6/netfilter/ip6_tables.c           |  103 ------------------------
 net/netfilter/xt_HMARK.c                  |    8 +-
 net/openvswitch/actions.c                 |   97 +++++++++++++++++++++++
 net/openvswitch/datapath.c                |   27 ++++++-
 net/openvswitch/flow.c                    |   28 ++++++-
 net/openvswitch/flow.h                    |    8 +-
 net/openvswitch/vport-netdev.c            |   14 +++-
 net/openvswitch/vport-netdev.h            |    3 +
 net/openvswitch/vport.c                   |    5 +-
 13 files changed, 304 insertions(+), 132 deletions(-)
