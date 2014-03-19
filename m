From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/4] introduce infrastructure for support of switch chip datapath
Date: Wed, 19 Mar 2014 16:33:48 +0100
Message-ID: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:57816 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965001AbaCSPd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 11:33:58 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so6745021eek.17
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:33:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just an early draft, RFC. I wanted to post this early to get the
feedback as soon as possible.

The basic idea is to introduce a generic infractructure to support various
switch chips in kernel. Also the idea is to benefit of currently existing
Open vSwitch userspace infrastructure.


The first patch does a split of structures which are not specific to OVS
into more generic ones that can be reused.


The second patch introduces the "switchdev" API itself. It should serve as
a glue between chip drivers on the one side and the "linked users" on the other.
Note that even though the only "linked user" in this patchset is OVS, it
is certainly possible to add another ones (sysfs, netlink, whatever).

The infrastructure is designed to be similar to for example linux bridge.
There is one netdevice representing a switch chip and one netdevice per every
port. These are bound together in classic slave-master way. The reason
to reuse the netdevices for port representation is that userspace can use
standard tools to get information about the ports, statistics, tcpdump, etc.


The third patch introduces a support for switchdev vports into OVS datapath.
After that, userspace would be able to create a switchdev DP for a switch chip,
to add switchdev ports to it and to use it in the same way as it would be
OVS SW datapath.


The fourth patch adds a dummy switch module. It is just an example of
switchdev driver implementation.


Any feedback very welcome!

Thanks.

Jiri

Jiri Pirko (4):
  openvswitch: split flow structures into ovs specific and generic ones
  net: introduce switchdev API
  openvswitch: Introduce support for switchdev based datapath
  net: introduce dummy switch

 drivers/net/Kconfig                        |   7 +
 drivers/net/Makefile                       |   1 +
 drivers/net/dummyswitch.c                  | 142 +++++++++++++
 include/linux/sw_flow.h                    | 105 +++++++++
 include/linux/switchdev.h                  |  62 ++++++
 include/uapi/linux/openvswitch.h           |   4 +
 net/Kconfig                                |  10 +
 net/core/Makefile                          |   1 +
 net/core/switchdev.c                       | 330 +++++++++++++++++++++++++++++
 net/openvswitch/Makefile                   |   4 +
 net/openvswitch/datapath.c                 |  90 +++++---
 net/openvswitch/datapath.h                 |  12 +-
 net/openvswitch/dp_notify.c                |   3 +-
 net/openvswitch/flow.c                     |  12 +-
 net/openvswitch/flow.h                     | 123 +++--------
 net/openvswitch/flow_netlink.c             |  24 +--
 net/openvswitch/flow_netlink.h             |   4 +-
 net/openvswitch/flow_table.c               | 100 ++++-----
 net/openvswitch/flow_table.h               |  18 +-
 net/openvswitch/vport-gre.c                |   4 +-
 net/openvswitch/vport-internal_switchdev.c | 148 +++++++++++++
 net/openvswitch/vport-internal_switchdev.h |  26 +++
 net/openvswitch/vport-netdev.c             |   4 +-
 net/openvswitch/vport-switchportdev.c      | 158 ++++++++++++++
 net/openvswitch/vport-switchportdev.h      |  24 +++
 net/openvswitch/vport-vxlan.c              |   2 +-
 net/openvswitch/vport.c                    |   6 +-
 net/openvswitch/vport.h                    |   4 +-
 28 files changed, 1218 insertions(+), 210 deletions(-)
 create mode 100644 drivers/net/dummyswitch.c
 create mode 100644 include/linux/sw_flow.h
 create mode 100644 include/linux/switchdev.h
 create mode 100644 net/core/switchdev.c
 create mode 100644 net/openvswitch/vport-internal_switchdev.c
 create mode 100644 net/openvswitch/vport-internal_switchdev.h
 create mode 100644 net/openvswitch/vport-switchportdev.c
 create mode 100644 net/openvswitch/vport-switchportdev.h

-- 
1.8.5.3
