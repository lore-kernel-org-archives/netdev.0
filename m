From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.57] datapath: Add basic MPLS support to kernel
Date: Fri, 16 May 2014 08:07:06 +0900
Message-ID: <1400195227-21265-1-git-send-email-horms@verge.net.au>
Cc: Ben Pfaff <blp@nicira.com>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33959 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839AbaEOXHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 19:07:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse, Hi Pravin, Hi All,

This patchset makes use of a whitelist to only allow mpls_push actions to
be applied to packets with an ethertype where the tag order is well defined
and implemented. This avoids the problem of where an MPLS LSE should be
added in relation to a VLAN or similar tag.

The list of allowed ethertypes is currently:

  - ETH_P_IP (0x0800)
  - ETH_P_ARP (0x0806)
  - ETH_P_RARP (0x0835)
  - ETH_P_IPV6 (0x86DD)
  - ETH_P_MPLS_UC (0x8847)
  - ETH_P_MPLS_MC (0x8847)


I have updated this patch since v2.56 to account for the new
sample action which does not have side effects. This has allowed
complex verification code in this patch to be replaced with something
significantly simpler and smaller.


Simon Horman (1):
  datapath: Add basic MPLS support to kernel

 OPENFLOW-1.1+                                   |   4 -
 datapath/Modules.mk                             |   1 +
 datapath/actions.c                              | 118 ++++++++++++++++++++++-
 datapath/datapath.c                             |   6 +-
 datapath/flow.c                                 |  29 ++++++
 datapath/flow.h                                 |  17 ++--
 datapath/flow_netlink.c                         | 119 ++++++++++++++++++++----
 datapath/flow_netlink.h                         |   2 +-
 datapath/linux/compat/gso.c                     |  70 +++++++++++---
 datapath/linux/compat/gso.h                     |  41 +++++++-
 datapath/linux/compat/include/linux/netdevice.h |   6 +-
 datapath/linux/compat/netdevice.c               |  10 +-
 datapath/mpls.h                                 |  15 +++
 include/linux/openvswitch.h                     |   9 +-
 14 files changed, 394 insertions(+), 53 deletions(-)
 create mode 100644 datapath/mpls.h

-- 
1.8.5.2
