From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH vxlan v2 0/8] openvswitch: Add vxlan tunneling support.
Date: Wed, 26 Jun 2013 13:13:16 -0700
Message-ID: <1372277596-17428-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:47522 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752452Ab3FZUN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:13:27 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so14691547pbb.19
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 13:13:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series is against vxlan tree.

First two patches fixes vxlan issues.  Next two patches
extends vxlan so that openvswitch can share vxlan udp port
with vxlan module. Rest of patches refactors vxlan data
plane so that ovs can share that code with vxlan module.
Last patch adds vxlan-vport to openvswitch.

Pravin B Shelar (8):
  vxlan: Fix module cleanup.
  vxlan: Fix vs->vni_list locking.
  vxlan: Allow multiple receive handlers.
  vxlan: Extend vxlan handlers for openvswitch.
  vxlan: Factor out vxlan send api.
  vxlan: Improve vxlan headroom calculation.
  vxlan: Add tx-vlan offload support.
  openvswitch: Add vxlan tunneling support.

 drivers/net/vxlan.c              |  434 +++++++++++++++++++++++---------------
 include/net/vxlan.h              |   35 +++
 include/uapi/linux/openvswitch.h |   11 +
 net/openvswitch/Kconfig          |    1 +
 net/openvswitch/Makefile         |    3 +-
 net/openvswitch/vport-vxlan.c    |  214 +++++++++++++++++++
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 8 files changed, 533 insertions(+), 169 deletions(-)
 create mode 100644 include/net/vxlan.h
 create mode 100644 net/openvswitch/vport-vxlan.c
