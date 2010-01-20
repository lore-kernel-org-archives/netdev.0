From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sfc: EFX_ETHTOOL_STAT calculates the offset of the efx##source_name's
 field in both cases
Date: Wed, 20 Jan 2010 03:08:30 +0100
Message-ID: <4B56659E.3040001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, Andrew Mor
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:57204 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505Ab0ATCDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 21:03:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EFX_ETHTOOL_STAT calculated the offset of the efx##source_name's field
Regardless of whether that field was NULL.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
This looks like a bug, but I am not sure whether I understood this correctly,
nor was it tested, was this intended?

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 6c0bbed..722bac7 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -41,7 +41,7 @@ struct efx_ethtool_stat {
 	.source = EFX_ETHTOOL_STAT_SOURCE_##source_name,		\
 	.offset = ((((field_type *) 0) ==				\
 		      &((struct efx_##source_name *)0)->field) ?	\
-		    offsetof(struct efx_##source_name, field) :		\
+		    offsetof(struct efx_##stat_name, field) :		\
 		    offsetof(struct efx_##source_name, field)),		\
 	.get_stat = get_stat_function,					\
 }
