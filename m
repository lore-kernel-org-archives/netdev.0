From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v5 0/7] openvswitch: VXLAN tunneling.
Date: Wed, 31 Jul 2013 16:14:17 -0700
Message-ID: <1375312457-18532-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:46816 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750834Ab3GaXOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:14:21 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so1424556pab.6
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 16:14:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First three vxlan patches extends vxlan so that openvswitch
can share vxlan udp port with vxlan module. Rest of patches
refactors vxlan data plane so that ovs can share that
code with vxlan module.
Last patch adds vxlan-vport to openvswitch.

Latest version disallow any udp port sharing between
kernel-vxlan and ovs-vxlan as suggested by Stephen Hemminger.

Pravin B Shelar (7):
  vxlan: Restructure vxlan socket apis.
  vxlan: Restructure vxlan receive for multiple protocols.
  vxlan: Extend vxlan handlers for openvswitch.
  vxlan: Factor out vxlan send api.
  vxlan: Improve vxlan headroom calculation.
  vxlan: Add tx-vlan offload support.
  openvswitch: Add vxlan tunneling support.

 drivers/net/vxlan.c              |  339 +++++++++++++++++++++++---------------
 include/net/vxlan.h              |   39 +++++
 include/uapi/linux/openvswitch.h |   11 ++
 net/openvswitch/Kconfig          |   13 ++
 net/openvswitch/Makefile         |    4 +
 net/openvswitch/vport-vxlan.c    |  206 +++++++++++++++++++++++
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 8 files changed, 482 insertions(+), 134 deletions(-)
 create mode 100644 include/net/vxlan.h
 create mode 100644 net/openvswitch/vport-vxlan.c
