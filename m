From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH 0/4] llc enhancements
Date: Fri,  4 Dec 2009 00:31:34 +0200
Message-ID: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: opurdila@ixiacom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:20102 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750765AbZLCWeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:34:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series introduces a couple of general enhancements to LLC
socket code as well as changes to scale the LLC socket lookup code for
a large number of interfaces needed for our uses cases (STP traffic
generation from a large number of ports, via virtual network
interfaces).

Octavian Purdila (4):
      llc: use dev_hard_header
      llc: add support for LLC_OPT_PKTINFO
      llc: use a device based hash table to speed up multicast delivery
      llc: replace the socket list with a local address based hash

 drivers/net/myri_sbus.c |    6 ++--
 include/linux/llc.h     |    7 ++++
 include/net/llc.h       |   39 ++++++++++++++++++++--
 include/net/llc_conn.h  |    2 +
 net/8021q/vlan_dev.c    |    7 ++--
 net/ethernet/eth.c      |    7 ++--
 net/llc/af_llc.c        |   29 ++++++++++++++++
 net/llc/llc_conn.c      |   82 ++++++++++++++++++++++++++++++++---------------
 net/llc/llc_core.c      |    7 +++-
 net/llc/llc_output.c    |   45 ++++---------------------
 net/llc/llc_proc.c      |   67 ++++++++++++++++++++++++--------------
 net/llc/llc_sap.c       |   18 ++++++----
 12 files changed, 205 insertions(+), 111 deletions(-)
