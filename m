From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipconfig: move ic_dev_xid under IPCONFIG_BOOTP
Date: Wed,  9 Jul 2014 20:35:21 +0200
Message-ID: <1404930921-14879-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Fengguang Wu <fengguang.wu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay004.isp.belgacom.be ([195.238.6.170]:52735 "EHLO
	mailrelay004.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756180AbaGISfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 14:35:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ic_dev_xid is only used in __init ic_bootp_recv under IPCONFIG_BOOTP
and __init ic_dynamic under IPCONFIG_DYNAMIC(which is itself defined
with the same IPCONFIG_BOOTP)

This patch fixes the following warning when IPCONFIG_BOOTP is not set:
>> net/ipv4/ipconfig.c:146:15: warning: 'ic_dev_xid' defined but not used [-Wunused-variable]
    static __be32 ic_dev_xid;  /* Device under configuration */

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: netdev@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/ipconfig.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index f0f3f9f..f02f594 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -143,8 +143,6 @@ __be32 ic_servaddr = NONE;	/* Boot server IP address */
 __be32 root_server_addr = NONE;	/* Address of NFS server */
 u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
-static __be32 ic_dev_xid;		/* Device under configuration */
-
 /* vendor class identifier */
 static char vendor_class_identifier[253] __initdata;
 
@@ -654,6 +652,7 @@ static struct packet_type bootp_packet_type __initdata = {
 	.func =	ic_bootp_recv,
 };
 
+static __be32 ic_dev_xid;		/* Device under configuration */
 
 /*
  *  Initialize DHCP/BOOTP extension fields in the request.
-- 
1.9.1
