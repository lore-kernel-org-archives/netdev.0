From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 1/4] rhashtable-test: add cond_resched() to thread test
Date: Fri, 20 Nov 2015 18:17:17 +0100
Message-ID: <1448039840-11367-2-git-send-email-phil@nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should fix for soft lockup bugs triggered on slow systems.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 8c1ad1c..63654e3 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -236,6 +236,8 @@ static int thread_lookup_test(struct thread_data *tdata)
 			       obj->value, key);
 			err++;
 		}
+
+		cond_resched();
 	}
 	return err;
 }
@@ -251,6 +253,7 @@ static int threadfunc(void *data)
 
 	for (i = 0; i < entries; i++) {
 		tdata->objs[i].value = (tdata->id << 16) | i;
+		cond_resched();
 		err = rhashtable_insert_fast(&ht, &tdata->objs[i].node,
 		                             test_rht_params);
 		if (err == -ENOMEM || err == -EBUSY) {
@@ -285,6 +288,8 @@ static int threadfunc(void *data)
 				goto out;
 			}
 			tdata->objs[i].value = TEST_INSERT_FAIL;
+
+			cond_resched();
 		}
 		err = thread_lookup_test(tdata);
 		if (err) {
-- 
2.1.2
