From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 05/08: xt_quota: fix incomplete initialization
Date: Thu, 23 Jul 2009 16:15:31 +0200 (MEST)
Message-ID: <20090723141530.19029.8546.sendpatchset@x2.localnet>
References: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 60cc46b2f32e6829efa4067914da11e4d64f421a
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 3 10:35:12 2009 +0200

    netfilter: xt_quota: fix incomplete initialization
    
    Upstream commit 6d62182f:
    
    Commit v2.6.29-rc5-872-gacc738f ("xtables: avoid pointer to self")
    forgot to copy the initial quota value supplied by iptables into the
    private structure, thus counting from whatever was in the memory
    kmalloc returned.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 01dd07b..98fc190 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -54,6 +54,7 @@ static bool quota_mt_check(const struct xt_mtchk_param *par)
 	if (q->master == NULL)
 		return -ENOMEM;
 
+	q->master->quota = q->quota;
 	return true;
 }
 
