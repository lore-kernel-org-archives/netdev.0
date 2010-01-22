From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] icmp: move icmp_err_convert[] to .rodata
Date: Fri, 22 Jan 2010 22:18:25 +0200
Message-ID: <20100122201824.GD22342@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:49786 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab0AVUS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 15:18:29 -0500
Received: by fxm20 with SMTP id 20so1739908fxm.21
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 12:18:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/icmp.h |    2 +-
 net/ipv4/icmp.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -28,7 +28,7 @@ struct icmp_err {
   unsigned	fatal:1;
 };
 
-extern struct icmp_err icmp_err_convert[];
+extern const struct icmp_err icmp_err_convert[];
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
 #define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmpmsg_statistics, field+256)
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -114,7 +114,7 @@ struct icmp_bxm {
 /* An array of errno for error messages from dest unreach. */
 /* RFC 1122: 3.2.2.1 States that NET_UNREACH, HOST_UNREACH and SR_FAILED MUST be considered 'transient errs'. */
 
-struct icmp_err icmp_err_convert[] = {
+const struct icmp_err icmp_err_convert[] = {
 	{
 		.errno = ENETUNREACH,	/* ICMP_NET_UNREACH */
 		.fatal = 0,
