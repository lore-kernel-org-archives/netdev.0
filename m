From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/2] workqueue: deprecate cancel_rearming_delayed_work[queue]()
Date: Tue, 14 Dec 2010 16:23:10 +0100
Message-ID: <4D078BDE.8060102@kernel.org>
References: <4D078B6D.5060202@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, benh@kernel.crashing.org, mchehab@infradead.org,
	davem@davemloft.net, netdev@vger.kernel.org, cbou@mail.ru,
	dwmw2@infradead.org, zbr@ioremap.net, gregkh@suse.de,
	bfields@fieldses.org, neilb@suse.de, aelder@sgi.com,
	xfs-masters@oss.sgi.com, cl@linux-foundation.org,
	penberg@cs.helsinki.fi, akpm@linux-foundation.org,
	netfilter-devel@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D078B6D.5060202@kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no in-kernel user left for these two obsolete functions.  Mark
them deprecated and schedule for removal during 2.6.39 cycle.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 Documentation/feature-removal-schedule.txt |   10 ++++++++++
 include/linux/workqueue.h                  |    4 ++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 6c2f55e..4ff47de 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -564,3 +564,13 @@ Why:	This field is deprecated. I2C device drivers shouldn't change their
 Who:	Jean Delvare <khali@linux-fr.org>

 ----------------------------
+
+What:	cancel_rearming_delayed_work[queue]()
+When:	2.6.39
+
+Why:	The functions have been superceded by cancel_delayed_work_sync()
+	quite some time ago.  The conversion is trivial and there is no
+	in-kernel user left.
+Who:	Tejun Heo <tj@kernel.org>
+
+----------------------------
diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 0c0771f..6b5193d 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -401,7 +401,7 @@ static inline bool __cancel_delayed_work(struct delayed_work *work)
 }

 /* Obsolete. use cancel_delayed_work_sync() */
-static inline
+static inline __deprecated
 void cancel_rearming_delayed_workqueue(struct workqueue_struct *wq,
 					struct delayed_work *work)
 {
@@ -409,7 +409,7 @@ void cancel_rearming_delayed_workqueue(struct workqueue_struct *wq,
 }

 /* Obsolete. use cancel_delayed_work_sync() */
-static inline
+static inline __deprecated
 void cancel_rearming_delayed_work(struct delayed_work *work)
 {
 	cancel_delayed_work_sync(work);
