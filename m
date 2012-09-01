From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] fddi: 64 bit bug in smt_add_para()
Date: Sat, 1 Sep 2012 12:57:40 -0700
Message-ID: <20120901195740.GG20741@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:36528 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755615Ab2IAT54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2012 15:57:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intent was to set 4 bytes of data so that's why the sp_len is set
to 4 on the next line.  The cast to u_long pointer clears 8 bytes
on 64 bit arches.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Code auditing work.  I don't have this hardware.  This bug is old.

diff --git a/drivers/net/fddi/skfp/pmf.c b/drivers/net/fddi/skfp/pmf.c
index 24d8566..441b4dc 100644
--- a/drivers/net/fddi/skfp/pmf.c
+++ b/drivers/net/fddi/skfp/pmf.c
@@ -673,7 +673,7 @@ void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
 			sm_pm_get_ls(smc,port_to_mib(smc,port))) ;
 		break ;
 	case SMT_P_REASON :
-		* (u_long *) to = 0 ;
+		*(u32 *)to = 0 ;
 		sp_len = 4 ;
 		goto sp_done ;
 	case SMT_P1033 :			/* time stamp */
