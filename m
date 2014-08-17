From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] carl9170: Replace rcu_dereference() with rcu_access_pointer()
Date: Sun, 17 Aug 2014 13:48:07 +0300
Message-ID: <20140817104806.GA14533@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: chunkeey@googlemail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rcu_dereference() call is used directly in a condition.
Since its return value is never dereferenced it is recommended to use
"rcu_access_pointer()" instead of "rcu_dereference()".
Therefore, this patch makes the replacement.

The following Coccinelle semantic patch was used:
@@
@@

(
 if(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
|
  while(
  (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
)

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 drivers/net/wireless/ath/carl9170/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index f8ded84..12018ff 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1431,7 +1431,7 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
 			return -EOPNOTSUPP;
 
 		rcu_read_lock();
-		if (rcu_dereference(sta_info->agg[tid])) {
+		if (rcu_access_pointer(sta_info->agg[tid])) {
 			rcu_read_unlock();
 			return -EBUSY;
 		}
-- 
1.9.1
