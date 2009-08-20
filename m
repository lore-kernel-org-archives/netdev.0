From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/01: xt_quota: fix wrong return value (error case)
Date: Thu, 20 Aug 2009 14:47:34 +0200
Message-ID: <4A8D45E6.6050800@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020003060509020103050206"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020003060509020103050206
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi Dave,

the following patch for 2.6.31 fixes a regression in the xt_quota module
introduced in 2.6.30-rc1, causing a crash when memory allocation fails.

Please apply, thanks.


--------------020003060509020103050206
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 53fa59e004cd02b1bd97edff965d063222bd0171
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Aug 13 15:42:17 2009 +0200

    netfilter: xt_quota: fix wrong return value (error case)
    
    Success was indicated on a memory allocation failure, thereby causing
    a crash due to a later NULL deref.
    (Affects v2.6.30-rc1 up to here.)
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 98fc190..390b7d0 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -52,7 +52,7 @@ static bool quota_mt_check(const struct xt_mtchk_param *par)
 
 	q->master = kmalloc(sizeof(*q->master), GFP_KERNEL);
 	if (q->master == NULL)
-		return -ENOMEM;
+		return false;
 
 	q->master->quota = q->quota;
 	return true;

--------------020003060509020103050206--
