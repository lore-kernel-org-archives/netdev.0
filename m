From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v3 1/3] netlabel: Deletion of an unnecessary check before
 the function call "cipso_v4_doi_putdef"
Date: Mon, 02 Feb 2015 11:25:30 +0100
Message-ID: <54CF509A.2000801@users.sourceforge.net>
References: <54CD4B5F.9010502@users.sourceforge.net>	<CAHC9VhQ5C32zRqG0emVUoMmuvBsV+TXvdNn+54iVyCPBNk9dDQ@mail.gmail.com>	<54CDFCDA.9010802@users.sourceforge.net> <20150201.123054.366525761630045391.davem@davemloft.net> <54CF4FEC.2010906@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <54CF4FEC.2010906@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 2 Feb 2015 10:01:45 +0100

The cipso_v4_doi_putdef() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Acked-by: Paul Moore <paul@paul-moore.com>
---
 net/netlabel/netlabel_mgmt.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 8b3b789..f5807f5 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -242,8 +242,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 	return 0;
 
 add_failure:
-	if (cipsov4)
-		cipso_v4_doi_putdef(cipsov4);
+	cipso_v4_doi_putdef(cipsov4);
 	if (entry)
 		kfree(entry->domain);
 	kfree(addrmap);
-- 
2.2.2

