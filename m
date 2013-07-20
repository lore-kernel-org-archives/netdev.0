From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.35 0/6] MPLS actions and matches
Date: Sat, 20 Jul 2013 12:06:57 +0900
Message-ID: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38124 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753622Ab3GTDHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 23:07:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series implements MPLS actions and matches based on work by
Ravi K, Leo Alterman, Yamahata-san and Joe Stringer.

This series provides two changes

* Provide user-space support for the VLAN/MPLS tag insertion order
  up to and including OpenFlow 1.2, and the different ordering
  specified from OpenFlow 1.3. In a nutshell the datapath always
  uses the OpenFlow 1.3 ordering, which is to always insert tags
  immediately after the L2 header, regardless of the presence of other
  tags. And ovs-vswtichd provides compatibility for the behaviour up
  to OpenFlow 1.2, which is that MPLS tags should follow VLAN tags
  if present.

* Adding basic MPLS action and match support to the kernel datapath


Differences between v2.35 and v2.34:

* Add support for the tag ordering specified up until OpenFlow 1.2 and
  the ordering specified from OpenFlow 1.3.

* Correct error in datapath patch's handling of GSO in the presence
  of MPLS and absence of VLANs.


Patch overview:

* The first 5 patches of this series are new,
  adding support for different tag ordering.
* The last patch is a revised version of the patch to add MPLS support
  to the datapath. It has been updated to use OpenFlow 1.3 tag ordering
  and resolve a GSO handling bug: both mentioned above. Its change log
  includes a history of changes.


To aid review this series is available in git at:

git://github.com/horms/openvswitch.git devel/mpls-v2.35


Patch list and overall diffstat:

Joe Stringer (5):
  odp: Only pass vlan_tci to commit_vlan_action()
  odp: Allow VLAN actions after MPLS actions
  ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
  ofp-actions: Add separate OpenFlow 1.3 action parser
  lib: Push MPLS tags in the OpenFlow 1.3 ordering

Simon Horman (1):
  datapath: Add basic MPLS support to kernel

 datapath/Modules.mk                             |    1 +
 datapath/actions.c                              |  125 ++++++-
 datapath/datapath.c                             |  254 +++++++++++--
 datapath/datapath.h                             |    9 +
 datapath/flow.c                                 |   58 ++-
 datapath/flow.h                                 |   17 +-
 datapath/linux/compat/gso.c                     |   50 ++-
 datapath/linux/compat/gso.h                     |   39 ++
 datapath/linux/compat/include/linux/netdevice.h |   12 -
 datapath/linux/compat/netdevice.c               |   28 --
 datapath/mpls.h                                 |   15 +
 datapath/tunnel.c                               |    1 +
 datapath/vport-netdev.c                         |   44 ++-
 include/linux/openvswitch.h                     |    7 +-
 lib/flow.c                                      |    2 +-
 lib/odp-util.c                                  |   22 +-
 lib/odp-util.h                                  |    4 +-
 lib/ofp-actions.c                               |   68 +++-
 lib/ofp-parse.c                                 |    1 +
 lib/ofp-util.c                                  |    3 +
 lib/ofp-util.h                                  |    1 +
 lib/packets.c                                   |   10 +-
 lib/packets.h                                   |    2 +-
 ofproto/ofproto-dpif-xlate.c                    |  101 +++--
 ofproto/ofproto-dpif-xlate.h                    |    5 +
 tests/ofproto-dpif.at                           |  446 +++++++++++++++++++++++
 26 files changed, 1195 insertions(+), 130 deletions(-)
 create mode 100644 datapath/mpls.h

-- 
1.7.10.4
