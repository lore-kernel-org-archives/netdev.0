From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 0/6] openvswitch: VXLAN tunneling.
Date: Tue, 23 Jul 2013 11:22:20 -0700
Message-ID: <1374603740-15377-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:50039 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933562Ab3GWSWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 14:22:25 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so8721175pbb.6
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 11:22:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First two patches extends vxlan so that openvswitch can
share vxlan udp port with vxlan module. Rest of patches
refactors vxlan data plane so that ovs can share that
code with vxlan module.
Last patch adds vxlan-vport to openvswitch.

Pravin B Shelar (6):
  vxlan: Allow multiple receive handlers.
  vxlan: Extend vxlan handlers for openvswitch.
  vxlan: Factor out vxlan send api.
  vxlan: Improve vxlan headroom calculation.
  vxlan: Add tx-vlan offload support.
  openvswitch: Add vxlan tunneling support.

 drivers/net/vxlan.c              |  474 ++++++++++++++++++++++++--------------
 include/net/vxlan.h              |   47 ++++
 include/uapi/linux/openvswitch.h |   11 +
 net/openvswitch/Kconfig          |   13 +
 net/openvswitch/Makefile         |    3 +-
 net/openvswitch/vport-vxlan.c    |  211 +++++++++++++++++
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 8 files changed, 588 insertions(+), 175 deletions(-)
 create mode 100644 include/net/vxlan.h
 create mode 100644 net/openvswitch/vport-vxlan.c
