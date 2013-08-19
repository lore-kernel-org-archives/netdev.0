From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v7 0/8] openvswitch: VXLAN tunneling.
Date: Mon, 19 Aug 2013 11:22:39 -0700
Message-ID: <1376936559-25427-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:33971 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751099Ab3HSSWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:22:46 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so4927525pad.33
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 11:22:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First four vxlan patches extends vxlan so that openvswitch
can share vxlan recv code. Rest of patches refactors vxlan
data plane so that ovs can share that code with vxlan module.
Last patch adds vxlan-vport to openvswitch.

v7 fixed first patch as suggested by Stephen Hemminger.
v6 series splits second patch into two and has few style fixes.
v5 series disallow any udp port sharing between
kernel-vxlan and ovs-vxlan as suggested by Stephen Hemminger.

Pravin B Shelar (8):
  vxlan: Restructure vxlan socket apis.
  vxlan: Restructure vxlan receive.
  vxlan: Add vxlan recv demux.
  vxlan: Extend vxlan handlers for openvswitch.
  vxlan: Factor out vxlan send api.
  vxlan: Improve vxlan headroom calculation.
  vxlan: Add tx-vlan offload support.
  openvswitch: Add vxlan tunneling support.

 drivers/net/vxlan.c              |  342 ++++++++++++++++++++++----------------
 include/net/vxlan.h              |   39 +++++
 include/uapi/linux/openvswitch.h |   11 ++
 net/openvswitch/Kconfig          |   13 ++
 net/openvswitch/Makefile         |    4 +
 net/openvswitch/vport-vxlan.c    |  204 +++++++++++++++++++++++
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 8 files changed, 477 insertions(+), 140 deletions(-)
 create mode 100644 include/net/vxlan.h
 create mode 100644 net/openvswitch/vport-vxlan.c
