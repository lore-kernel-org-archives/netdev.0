From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 0/7] openvswitch: VXLAN tunneling.
Date: Fri, 26 Jul 2013 16:14:42 -0700
Message-ID: <1374880482-2846-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:56687 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758315Ab3GZXOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 19:14:46 -0400
Received: by mail-pd0-f171.google.com with SMTP id y14so3405686pdi.16
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 16:14:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First three vxlan patches extends vxlan so that openvswitch 
can share vxlan udp port with vxlan module. Rest of patches
refactors vxlan data plane so that ovs can share that
code with vxlan module.
Last patch adds vxlan-vport to openvswitch.

Pravin B Shelar (7):
  vxlan: Add vxlan_handler.
  vxlan: Restructure vxlan receive for multiple protocol handlers.
  vxlan: Extend vxlan handlers for openvswitch.
  vxlan: Factor out vxlan send api.
  vxlan: Improve vxlan headroom calculation.
  vxlan: Add tx-vlan offload support.
  openvswitch: Add vxlan tunneling support.

 drivers/net/vxlan.c              |  477 ++++++++++++++++++++++++--------------
 include/net/vxlan.h              |   47 ++++
 include/uapi/linux/openvswitch.h |   11 +
 net/openvswitch/Kconfig          |   13 +
 net/openvswitch/Makefile         |    4 +
 net/openvswitch/vport-vxlan.c    |  208 +++++++++++++++++
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 8 files changed, 590 insertions(+), 174 deletions(-)
 create mode 100644 include/net/vxlan.h
 create mode 100644 net/openvswitch/vport-vxlan.c
