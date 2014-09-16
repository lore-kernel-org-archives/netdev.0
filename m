From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next v3] Open vSwitch
Date: Tue, 16 Sep 2014 00:23:29 -0700
Message-ID: <1410852209-1456-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:60046 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752485AbaIPHXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 03:23:01 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so8348658pad.35
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 00:23:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds recirculation and hash action to OVS.
First patch removes pointer to stack object. Next three patches
does code restructuring which is required for last patch.
Recirculation implementation is changed, according to comments from
David Miller, to avoid using recursive calls in OVS. It is using
queue to record recirc action and deferred recirc is executed at
the end of current actions execution.

v1-v2:
Changed subsystem name in subject to openvswitch
v2-v3:
Added patch to remove pkt_key pointer from skb->cb.

----------------------------------------------------------------
The following changes since commit c1f570a6abc192f047550743f9957b617af605af:

  net: dsa: fix mii_bus to host_dev replacement (2014-09-15 17:52:48 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to 971427f353f3c42c8dcef62e7124440df68eb809:

  openvswitch: Add recirc and hash action. (2014-09-15 23:28:14 -0700)

----------------------------------------------------------------
Andy Zhou (2):
      openvswitch: simplify sample action implementation
      openvswitch: Add recirc and hash action.

Pravin B Shelar (3):
      openvswitch: Remove pkt_key from OVS_CB
      openvswitch: refactor ovs flow extract API.
      openvswitch: Use tun_key only for egress tunnel path.

 include/uapi/linux/openvswitch.h |  26 ++++
 net/openvswitch/actions.c        | 258 +++++++++++++++++++++++++++++++++------
 net/openvswitch/datapath.c       |  52 ++++----
 net/openvswitch/datapath.h       |  23 ++--
 net/openvswitch/flow.c           |  57 ++++++---
 net/openvswitch/flow.h           |  10 +-
 net/openvswitch/flow_netlink.c   |  65 +++++++---
 net/openvswitch/flow_netlink.h   |   4 +-
 net/openvswitch/vport-gre.c      |  23 ++--
 net/openvswitch/vport-vxlan.c    |  21 ++--
 net/openvswitch/vport.c          |  15 ++-
 11 files changed, 428 insertions(+), 126 deletions(-)
