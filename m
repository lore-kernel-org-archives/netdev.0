From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 4/4] ppp: use for_each_set_bit_from
Date: Tue,  3 Apr 2012 17:47:16 +0900
Message-ID: <1333442836-9947-4-git-send-email-akinobu.mita@gmail.com>
References: <1333442836-9947-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Kozlov <xeb@mail.ru>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333442836-9947-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use for_each_set_bit_from to iterate over all the set bit in a memory
region.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Dmitry Kozlov <xeb@mail.ru>
Cc: netdev@vger.kernel.org
---
 drivers/net/ppp/pptp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 885dbdd..72b50f5 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -116,8 +116,8 @@ static int lookup_chan_dst(u16 call_id, __be32 d_addr)
 	int i;
 
 	rcu_read_lock();
-	for (i = find_next_bit(callid_bitmap, MAX_CALLID, 1); i < MAX_CALLID;
-	     i = find_next_bit(callid_bitmap, MAX_CALLID, i + 1)) {
+	i = 1;
+	for_each_set_bit_from(i, callid_bitmap, MAX_CALLID) {
 		sock = rcu_dereference(callid_sock[i]);
 		if (!sock)
 			continue;
-- 
1.7.4.4
