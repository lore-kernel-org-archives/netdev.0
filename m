From: Ira Snyder <kernel@irasnyder.com>
Subject: [PATCH] tg3: add missing unlock in tg3_open() error path
Date: Tue, 21 Nov 2006 14:23:11 -0800
Message-ID: <20061121142311.4d1b9510.kernel@irasnyder.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gilford.textdrive.com ([207.7.108.53]:2271 "EHLO
	gilford.textdrive.com") by vger.kernel.org with ESMTP
	id S1756774AbWKUWXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 17:23:12 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] tg3: add missing unlock in tg3_open() error path

Sparse noticed a locking imbalance in tg3_open(). This patch adds an unlock
to one of the error paths, so that tg3_open() always exits without the
lock held.

Signed-off-by: Ira W. Snyder <kernel@irasnyder.com>

---
commit e114d89ecaab99bc175c1db497d9c851e750ca3d
tree d4e82d18cd108d9dea4d01b81890d86c0519048d
parent f84c313680a21fd6c487ac17f69c4c115472e257
author Ira W. Snyder <kernel@irasnyder.com> Mon, 20 Nov 2006 11:03:03 -0800
committer Ira W. Snyder <kernel@irasnyder.com> Mon, 20 Nov 2006 11:03:03 -0800

 drivers/net/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1dbdd6b..c20bb99 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6979,8 +6979,10 @@ static int tg3_open(struct net_device *d
 	tg3_full_lock(tp, 0);
 
 	err = tg3_set_power_state(tp, PCI_D0);
-	if (err)
+	if (err) {
+		tg3_full_unlock(tp);
 		return err;
+	}
 
 	tg3_disable_ints(tp);
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
