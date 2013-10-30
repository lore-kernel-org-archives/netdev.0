From: Jesse Gross <jesse@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Tue, 29 Oct 2013 17:22:13 -0700
Message-ID: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:33372 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752527Ab3J3AWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:31 -0400
Received: by mail-pb0-f45.google.com with SMTP id ma3so585569pbc.4
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A set of updates for net-next/3.13. Major changes are:
 * Restructure flow handling code to be more logically organized and
   easier to read.
 * Previously flow state was effectively per-CPU but this is no longer
   true with the addition of wildcarded flows (megaflows). While good
   for flow setup rates, it is bad for stats updates. Stats are now
   per-CPU again to get the best of both worlds.
 * Rehashing of the flow table is moved from a workqueue to flow
   installation time. Before, heavy load could block the workqueue for
   excessive periods of time.
 * Additional debugging information is provided to help diagnose megaflows.
 * It's now possible to match on TCP flags.

The following changes since commit 272b98c6455f00884f0350f775c5342358ebb73f:

  Linux 3.12-rc1 (2013-09-16 16:17:51 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to c7e8b9659587449b21ee68d7aee0cacadf650cce:

  openvswitch: TCP flags matching support. (2013-10-23 02:19:50 -0700)

----------------------------------------------------------------
Andy Zhou (1):
      openvswitch: collect mega flow mask stats

Jarno Rajahalme (2):
      openvswitch: Widen TCP flags handling.
      openvswitch: TCP flags matching support.

Pravin B Shelar (6):
      openvswitch: Move flow table rehashing to flow install.
      openvswitch: Restructure datapath.c and flow.c
      openvswitch: Move mega-flow list out of rehashing struct.
      openvswitch: Simplify mega-flow APIs.
      openvswitch: Per cpu flow stats.
      openvswitch: Enable all GSO features on internal port.

Wei Yongjun (2):
      openvswitch: remove duplicated include from vport-vxlan.c
      openvswitch: remove duplicated include from vport-gre.c

 include/uapi/linux/openvswitch.h     |   18 +-
 net/openvswitch/Makefile             |    2 +
 net/openvswitch/datapath.c           |  721 ++-------------
 net/openvswitch/datapath.h           |    9 +-
 net/openvswitch/flow.c               | 1631 ++--------------------------------
 net/openvswitch/flow.h               |  148 +--
 net/openvswitch/flow_netlink.c       | 1630 +++++++++++++++++++++++++++++++++
 net/openvswitch/flow_netlink.h       |   60 ++
 net/openvswitch/flow_table.c         |  600 +++++++++++++
 net/openvswitch/flow_table.h         |   81 ++
 net/openvswitch/vport-gre.c          |    2 -
 net/openvswitch/vport-internal_dev.c |    2 +-
 net/openvswitch/vport-vxlan.c        |    1 -
 13 files changed, 2590 insertions(+), 2315 deletions(-)
 create mode 100644 net/openvswitch/flow_netlink.c
 create mode 100644 net/openvswitch/flow_netlink.h
 create mode 100644 net/openvswitch/flow_table.c
 create mode 100644 net/openvswitch/flow_table.h
