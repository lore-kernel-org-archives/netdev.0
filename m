From: Bryan O'Sullivan <bos@pathscale.com>
Subject: [PATCH 33 of 39] IB/ipath - read/write correct sizes through diag
	interface
Date: Thu, 29 Jun 2006 14:41:24 -0700
Message-ID: <a7c1ad1e090b34dab632.1151617284@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:39311 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S932912AbWF2VoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 17:44:10 -0400
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We must increment uaddr by size we are reading or writing, since it's
passed as a char *, not a pointer to the appropriate size.

Signed-off-by: Dave Olson <dave.olson@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 8fbb5d71823a -r a7c1ad1e090b drivers/infiniband/hw/ipath/ipath_diag.c
--- a/drivers/infiniband/hw/ipath/ipath_diag.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_diag.c	Thu Jun 29 14:33:26 2006 -0700
@@ -115,7 +115,7 @@ static int ipath_read_umem64(struct ipat
 			goto bail;
 		}
 		reg_addr++;
-		uaddr++;
+		uaddr += sizeof(u64);
 	}
 	ret = 0;
 bail:
@@ -154,7 +154,7 @@ static int ipath_write_umem64(struct ipa
 		writeq(data, reg_addr);
 
 		reg_addr++;
-		uaddr++;
+		uaddr += sizeof(u64);
 	}
 	ret = 0;
 bail:
@@ -192,7 +192,8 @@ static int ipath_read_umem32(struct ipat
 		}
 
 		reg_addr++;
-		uaddr++;
+		uaddr += sizeof(u32);
+
 	}
 	ret = 0;
 bail:
@@ -231,7 +232,7 @@ static int ipath_write_umem32(struct ipa
 		writel(data, reg_addr);
 
 		reg_addr++;
-		uaddr++;
+		uaddr += sizeof(u32);
 	}
 	ret = 0;
 bail:
