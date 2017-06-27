From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/14] nfp: remove unused nfp_cpp_area_check_range()
Date: Tue, 27 Jun 2017 00:50:18 -0700
Message-ID: <20170627075028.4009-5-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35183 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751498AbdF0HvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:10 -0400
Received: by mail-pf0-f169.google.com with SMTP id c73so12614556pfk.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:09 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused nfp_cpp_area_check_range() function.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h    |  2 --
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c    | 21 ---------------------
 2 files changed, 23 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
index 235dd023d9b9..5798adc57cbc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
@@ -242,8 +242,6 @@ int nfp_cpp_area_read(struct nfp_cpp_area *area, unsigned long offset,
 		      void *buffer, size_t length);
 int nfp_cpp_area_write(struct nfp_cpp_area *area, unsigned long offset,
 		       const void *buffer, size_t length);
-int nfp_cpp_area_check_range(struct nfp_cpp_area *area,
-			     unsigned long long offset, unsigned long size);
 const char *nfp_cpp_area_name(struct nfp_cpp_area *cpp_area);
 void *nfp_cpp_area_priv(struct nfp_cpp_area *cpp_area);
 struct nfp_cpp *nfp_cpp_area_cpp(struct nfp_cpp_area *cpp_area);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 7d5d7293efed..04dd5758ecf5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -571,27 +571,6 @@ int nfp_cpp_area_write(struct nfp_cpp_area *area,
 }
 
 /**
- * nfp_cpp_area_check_range() - check if address range fits in CPP area
- * @area:	CPP area handle
- * @offset:	offset into CPP target
- * @length:	size of address range in bytes
- *
- * Check if address range fits within CPP area.  Return 0 if area
- * fits or -EFAULT on error.
- *
- * Return: 0, or -ERRNO
- */
-int nfp_cpp_area_check_range(struct nfp_cpp_area *area,
-			     unsigned long long offset, unsigned long length)
-{
-	if (offset < area->offset ||
-	    offset + length > area->offset + area->size)
-		return -EFAULT;
-
-	return 0;
-}
-
-/**
  * nfp_cpp_area_name() - return name of a CPP area
  * @cpp_area:	CPP area handle
  *
-- 
2.11.0
