From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v7 0/8] openvswitch: VXLAN tunneling.
Date: Mon,  5 Aug 2013 10:47:02 -0700
Message-ID: <1375724822-19299-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:47308 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753612Ab3HERrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 13:47:24 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so3497175pdj.35
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 10:47:06 -0700 (PDT)
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
