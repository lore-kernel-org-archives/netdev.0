From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv5 net-next 0/3] sunvnet: add jumbo frames support
Date: Wed, 17 Sep 2014 16:49:32 -0400
Message-ID: <5419F3DC.60104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17348 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089AbaIQUti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 16:49:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set updates the sunvnet driver to version 1.6 of the VIO protocol
to support per-port exchange of MTU information and allow non-standard MTU
sizes, including jumbo frames.

Using large MTUs shows a > 4X throughput improvement Linux-Solaris
and > 8X throughput improvement Linux-Linux.

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

David L Stevens (3):
  sunvnet: upgrade to VIO protocol version 1.6
  sunvnet: allow admin to set sunvnet MTU
  sunvnet: generate ICMP PTMUD messages for smaller port MTUs

 arch/sparc/include/asm/vio.h       |   44 ++++++++++-
 arch/sparc/kernel/ldc.c            |    2 +-
 arch/sparc/kernel/viohs.c          |   14 +++-
 drivers/net/ethernet/sun/sunvnet.c |  146 +++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sun/sunvnet.h |    7 ++-
 5 files changed, 187 insertions(+), 26 deletions(-)
