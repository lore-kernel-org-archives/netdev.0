From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next v2] Open vSwitch
Date: Thu, 11 Sep 2014 16:27:54 -0700
Message-ID: <1410478074-1407-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:41849 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751109AbaIKX13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:27:29 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so8871873pdb.14
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 16:27:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds recirculation and hash action to OVS.
First three patches does code restructuring which is required
for last patch.
Recirculation implementation is changed, according to comments from
David Miller, to avoid using recursive calls in OVS. It is using
queue to record recirc action and deferred recirc is executed at
the end of current actions execution.

v1-v2:
Changed subsystem name in subject to openvswitch
----------------------------------------------------------------
The following changes since commit b954d83421d51d822c42e5ab7b65069b25ad3005:

  net: bpf: only build bpf_jit_binary_{alloc, free}() when jit selected (2014-09-10 14:05:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to ee468f5c08e07229ac850e63d74236c3b85f28d5:

  openvswitch: Add recirc and hash action. (2014-09-11 16:15:36 -0700)

----------------------------------------------------------------
Andy Zhou (2):
      openvswitch: simplify sample action implementation
      openvswitch: Add recirc and hash action.

Pravin B Shelar (2):
      openvswitch: refactor ovs flow extract API.
      openvswitch: Use tun_key only for egress tunnel path.

 include/uapi/linux/openvswitch.h |  26 +++++
 net/openvswitch/actions.c        | 247 ++++++++++++++++++++++++++++++++++-----
 net/openvswitch/datapath.c       |  52 +++++----
 net/openvswitch/datapath.h       |  17 ++-
 net/openvswitch/flow.c           |  55 ++++++---
 net/openvswitch/flow.h           |  10 +-
 net/openvswitch/flow_netlink.c   |  63 +++++++---
 net/openvswitch/flow_netlink.h   |   4 +-
 net/openvswitch/vport-gre.c      |  22 ++--
 net/openvswitch/vport-vxlan.c    |  20 ++--
 net/openvswitch/vport.c          |  13 ++-
 11 files changed, 419 insertions(+), 110 deletions(-)
