From: roopa@cumulusnetworks.com
Subject: [RFC PATCH 1/4] rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate kernel object offload to hardware
Date: Fri, 21 Nov 2014 14:49:27 -0800
Message-ID: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com>
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
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36829 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbaKUWtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 17:49:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds new flags in netlink header nlmsg_flags to signal if the
message is for the kernel, hw or both.

This can be used to indicate hw offload for all kind of objects
routes, fdb entries, neighs, link objects like bonds, bridges, vxlan.

Adding it in the header makes it possible to use it accross all objects and
across all messages (sets/gets/deletes).

Other alternative to this is a per kernel object netlink attribute/flag.
But that leads to duplicating the attribute in different subsystems.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/netlink.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 1a85940..f78522d 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -54,6 +54,8 @@ struct nlmsghdr {
 #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
 #define NLM_F_ECHO		8	/* Echo this request 		*/
 #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
++#define NLM_F_KERNEL       32      /* This msg is only for the kernel */
+#define NLM_F_HW_OFFLOAD	64	/* offload this msg to hw */
 
 /* Modifiers to GET request */
 #define NLM_F_ROOT	0x100	/* specify tree	root	*/
-- 
1.7.10.4
