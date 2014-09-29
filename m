From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv8 net-next 0/4] sunvnet: add jumbo frames support
Date: Mon, 29 Sep 2014 15:53:36 -0400
Message-ID: <5429B8C0.6080807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Raghuram Kothahota <raghuram.kothakota@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28788 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaI2TxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:53:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set updates the sunvnet driver to version 1.6 of the VIO protocol
to support per-port exchange of MTU information and allow non-standard MTU
sizes, including jumbo frames.

Using large MTUs shows a nearly 5X throughput improvement Linux-Solaris
and > 10X throughput improvement Linux-Linux.

Changes from v7:
	-handle skb allocation failures in vnet_skb_shape()
	 per Dave Miller <davem@davemloft.net>
Changes from v6:
	-made kernel transmit path zero-copy to remove memory n^2 scaling issue
	 raised by Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Changes from v5:
	- fixed comment per Sowmini Varadhan <sowmini.varadhan@oracle.com>
Changes from v4:
	- changed VNET_MAXPACKET per David Laight <David.Laight@ACULAB.COM>
	- added cookies to support non-contiguous buffers of max size
Changes from v3:
	- added version functions per Dave Miller <davem@davemloft.net>
	- moved rmtu to vnet_port per Dave Miller <davem@davemloft.net>
	- explicitly set options bits and capability flags to 0 per
		Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Changes from v2:
	- make checkpatch clean
Changes from v1:
	- fix brace formatting per Dave Miller <davem@davemloft.net>

David L Stevens (4):
  sunvnet: upgrade to VIO protocol version 1.6
  sunvnet: make transmit path zero-copy in the kernel
  sunvnet: allow admin to set sunvnet MTU
  sunvnet: generate ICMP PTMUD messages for smaller port MTUs

 arch/sparc/include/asm/vio.h       |   44 +++++-
 arch/sparc/kernel/ldc.c            |    2 +-
 arch/sparc/kernel/viohs.c          |   14 ++-
 drivers/net/ethernet/sun/sunvnet.c |  316 +++++++++++++++++++++++++++++-------
 drivers/net/ethernet/sun/sunvnet.h |    9 +-
 5 files changed, 318 insertions(+), 67 deletions(-)
