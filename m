From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Thu, 11 Sep 2014 15:01:29 -0700
Message-ID: <1410472889-1417-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog013.obsmtp.com ([74.125.150.66]:40846 "HELO
	na6sys009bog013.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752014AbaIKWuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:50:19 -0400
Received: by mail-pd0-f171.google.com with SMTP id p10so11334864pdj.2
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:50:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds recirculation and hash action to OVS.
First three patches does code restructuring which is required
for last patch.
Recirculation implementation is changed, according to comments from
David Miller, to avoid using recursive calls in OVS. It is using
queue to record recirc action and deferred recirc is executed at
the end of current actions execution.

----------------------------------------------------------------
The following changes since commit b954d83421d51d822c42e5ab7b65069b25ad3005:

  net: bpf: only build bpf_jit_binary_{alloc, free}() when jit selected (2014-09-10 14:05:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to 9b8ede54a8bd319789e8bceb19789463bb944701:

  openvswitch: Add recirc and hash action. (2014-09-11 13:35:29 -0700)

----------------------------------------------------------------
Andy Zhou (2):
      datapath: simplify sample action implementation
      openvswitch: Add recirc and hash action.

Pravin B Shelar (2):
      datapath: refactor ovs flow extract API.
      datapath: Use tun_key only for egress tunnel path.

 include/uapi/linux/openvswitch.h |  26 +++++
 net/openvswitch/actions.c        | 247 ++++++++++++++++++++++++++++++++++-----
 net/openvswitch/datapath.c       |  52 +++++----
 net/openvswitch/datapath.h       |  17 ++-
 net/openvswitch/flow.c           |  54 +++++++--
 net/openvswitch/flow.h           |  10 +-
 net/openvswitch/flow_netlink.c   |  63 +++++++---
 net/openvswitch/flow_netlink.h   |   4 +-
 net/openvswitch/vport-gre.c      |  22 ++--
 net/openvswitch/vport-vxlan.c    |  20 ++--
 net/openvswitch/vport.c          |  13 ++-
 11 files changed, 419 insertions(+), 109 deletions(-)
