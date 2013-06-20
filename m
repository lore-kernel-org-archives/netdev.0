From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/8] openvswitch: Add vxlan tunneling support.
Date: Thu, 20 Jun 2013 00:26:15 -0700
Message-ID: <1371713175-8037-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:35914 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753968Ab3FTH0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 03:26:23 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so5941268pde.32
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 00:26:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First two patches fixes vxlan issues.  Next two patches
extends vxlan so that openvswitch can share vxlan udp port
with vxlan module. Rest of patches refactors vxlan data
plane so that ovs can share that code with vxlan module.
Last patch adds vxlan-vport to openvswitch.

Pravin B Shelar (8):
  vxlan: Fix error handling while creating device.
  vxlan: Fix sparse wornings.
  vxlan: Allow multiple recieve handlers.
  vxlan: Extend vxlan handlers for openvswitch.
  vxlan: Factor out vxlan send api.
  vxlan: Improve vxlan headroom calculation.
  vxlan: Add tx-vlan offload support.
  openvswitch: Add vxlan tunneling support.

 drivers/net/vxlan.c              |  337 +++++++++++++++++++++++++-------------
 include/net/vxlan.h              |   33 ++++
 include/uapi/linux/openvswitch.h |   11 ++
 net/openvswitch/Kconfig          |    1 +
 net/openvswitch/Makefile         |    3 +-
 net/openvswitch/vport-vxlan.c    |  220 +++++++++++++++++++++++++
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 8 files changed, 490 insertions(+), 119 deletions(-)
 create mode 100644 include/net/vxlan.h
 create mode 100644 net/openvswitch/vport-vxlan.c
