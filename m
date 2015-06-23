From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] dcb : Fix incorrect documentation for struct dcb_app
Date: Mon, 22 Jun 2015 17:44:35 -0700
Message-ID: <1435020275-2819-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, john.r.fastabend@intel.com,
	shanim@mellanox.com, ogerlitz@mellanox.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14081 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752077AbbFWAo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 20:44:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While IEEE and CEE use the same structure to store apps, the selector
and priority fields for both are different. Only the priority field is
explained, add documentation explaining how the selector field differs
for both.

cgdcbxd code shows an example of how selector fields differ.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 include/uapi/linux/dcbnl.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/dcbnl.h b/include/uapi/linux/dcbnl.h
index 6497d79..3ea470f 100644
--- a/include/uapi/linux/dcbnl.h
+++ b/include/uapi/linux/dcbnl.h
@@ -207,8 +207,7 @@ struct cee_pfc {
 #define IEEE_8021QAZ_APP_SEL_ANY	4
 
 /* This structure contains the IEEE 802.1Qaz APP managed object. This
- * object is also used for the CEE std as well. There is no difference
- * between the objects.
+ * object is also used for the CEE std as well.
  *
  * @selector: protocol identifier type
  * @protocol: protocol of type indicated
@@ -216,13 +215,18 @@ struct cee_pfc {
  *            8-bit 802.1p user priority bitmap for CEE
  *
  * ----
- *  Selector field values
+ *  Selector field values for IEEE 802.1Qaz
  *	0	Reserved
  *	1	Ethertype
  *	2	Well known port number over TCP or SCTP
  *	3	Well known port number over UDP or DCCP
  *	4	Well known port number over TCP, SCTP, UDP, or DCCP
  *	5-7	Reserved
+ *
+ *  Selector field values for CEE
+ *	0	Ethertype
+ *	1	Well known port number over TCP or UDP
+ *	2-3	Reserved
  */
 struct dcb_app {
 	__u8	selector;
-- 
2.4.4
