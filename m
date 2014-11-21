From: roopa@cumulusnetworks.com
Subject: [RFC PATCH 0/4] switch device: offload policy attributes
Date: Fri, 21 Nov 2014 14:49:26 -0800
Message-ID: <1416610170-21224-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shrijeet@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36801 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbaKUWtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 17:49:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>


This series aims at introducing new policy attibutes/flags to enable
selective offloading of kernel network objects.
This is in the context of supporting switch devices in the linux kernel.

Assumption:
    - All kernel network objects (routes, neighs, bridges, bonds, vxlans)
      can be offloaded (This is true today with a few exceptions maybe)

policy points:
    - By default all objects exist in software (kernel)
    - Per object flag to add/del/show in kernel, hardware or both
    - System global option to turn on/off offloads for all network objects.
      This is for systems who want to turn offloading on for all network objects
      by default. us :). Apps dont need to know about offloading in this
      model. (TBD)

Patches are based on jiri/sfeldma's rocker work.

Apologize for the incomplete and untested code. This is a sample patch
 to get some initial feedback.

Roopa Prabhu (4):
  rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate kernel object
    offload to hardware
  netdev: new feature flag NETIF_F_HW_OFFLOAD to indicate netdev object
    offload to hardware
  swdevice: new generic op to set bridge port attr
  bridge: make hw offload conditional on bridge and bridge port offload
    flags

 include/linux/netdev_features.h |    1 +
 include/net/switchdev.h         |    8 ++++++-
 include/uapi/linux/netlink.h    |    2 ++
 net/bridge/br_netlink.c         |   50 +++++++++++++++++++++++++++++++--------
 net/bridge/br_private.h         |    2 ++
 net/bridge/br_stp.c             |    9 ++++---
 net/bridge/br_stp_if.c          |    8 +++++--
 net/core/rtnetlink.c            |    7 ++++++
 net/switchdev/switchdev.c       |   17 +++++++++++++
 9 files changed, 88 insertions(+), 16 deletions(-)

-- 
1.7.10.4
