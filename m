From: Jesse Gross <jesse@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Tue, 16 Apr 2013 14:00:09 -0700
Message-ID: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:51589 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965213Ab3DPVAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:00:13 -0400
Received: by mail-pa0-f71.google.com with SMTP id fb10so793455pad.10
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:00:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of improvements for net-next/3.10.

Highlights include:
 * Properly exposing linux/openvswitch.h to userspace after the uapi changes.
 * Simplification of locking. It immediately makes things simpler to reason about and avoids holding RTNL mutex for longer than necessary. In the near future it will also enable tunnel registration and more fine-grained locking.
 * Miscellaneous cleanups and simplifications.

The following changes since commit f498354793d57479d4e1b0f39969acd66737234c:

  qlcnic: Bump up the version to 5.2.39 (2013-03-29 15:51:06 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to e0f0ecf33c3f13401f90bff5afdc3ed1bb40b9af:

  openvswitch: Use generic struct pcpu_tstats. (2013-04-15 14:56:25 -0700)

----------------------------------------------------------------
Andy Zhou (1):
      openvswitch: datapath.h: Fix a stale comment.

Pravin B Shelar (2):
      openvswitch: Simplify datapath locking.
      openvswitch: Use generic struct pcpu_tstats.

Thomas Graf (7):
      openvswitch: Specify the minimal length of OVS_PACKET_ATTR_PACKET in the policy
      openvswitch: Use nla_memcpy() to memcpy() data from attributes
      openvswitch: Refine Netlink message size calculation and kill FLOW_BUFSIZE
      openvswitch: Move common genl notify code into ovs_notify()
      openvswitch: Use ETH_ALEN to define ethernet addresses
      openvswitch: Expose <linux/openvswitch.h> to userspace
      openvswitch: Don't insert empty OVS_VPORT_ATTR_OPTIONS attribute

 include/linux/openvswitch.h          |  432 +-------------------------------
 include/uapi/linux/Kbuild            |    1 +
 include/uapi/linux/openvswitch.h     |  456 ++++++++++++++++++++++++++++++++++
 net/openvswitch/datapath.c           |  393 +++++++++++++++++------------
 net/openvswitch/datapath.h           |   70 ++++--
 net/openvswitch/dp_notify.c          |   82 ++++--
 net/openvswitch/flow.c               |    2 +-
 net/openvswitch/flow.h               |   21 --
 net/openvswitch/vport-internal_dev.c |    6 +
 net/openvswitch/vport-netdev.c       |    8 +-
 net/openvswitch/vport.c              |   58 +++--
 net/openvswitch/vport.h              |   15 +-
 12 files changed, 849 insertions(+), 695 deletions(-)
 create mode 100644 include/uapi/linux/openvswitch.h
