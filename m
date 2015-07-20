From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next] net/vxlan: Fix kernel unaligned access in
 __vxlan_find_mac
Date: Mon, 20 Jul 2015 09:54:50 +0200
Message-ID: <20150720075450.GB20398@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, therbert@google.com,
	marcelo.leitner@gmail.com, nicolas.dichtel@6wind.com,
	tgraf@suug.ch, jiri@resnulli.us, jbenc@redhat.com,
	azhou@nicira.com, jesse@nicira.com, sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25684 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbbGTHzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 03:55:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


__vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
which triggers unaligned access messages, so rearrange vxlan_fdb
to avoid this in the most non-intrusive way.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: Alexander Duyck comments: place eth_addr[] to be 64b aligned

 drivers/net/vxlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 34c519e..ec86a11 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -106,9 +106,9 @@ struct vxlan_fdb {
 	unsigned long	  updated;	/* jiffies */
 	unsigned long	  used;
 	struct list_head  remotes;
+	u8		  eth_addr[ETH_ALEN];
 	u16		  state;	/* see ndm_state */
 	u8		  flags;	/* see ndm_flags */
-	u8		  eth_addr[ETH_ALEN];
 };
 
 /* Pseudo network device */
-- 
1.7.1
