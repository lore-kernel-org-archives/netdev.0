From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH 1/2] siw: Fix ib_register_device() for > v2.6.34 kernels
Date: Wed, 22 Sep 2010 13:30:17 -0700
Message-ID: <1285187417-10928-1-git-send-email-nab@linux-iscsi.org>
Cc: David Miller <davem@davemloft.net>,
	Matthew Wilcox <willy@linux.intel.com>,
	Andi Keen <ak@linux.intel.com>,
	Roland Dreier <rdreier@cisco.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bernard Metzler <BMT@zurich.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Bellinger <nab@linux-iscsi.org>

This patch adds a LINUX_VERSION_CODE > v2.6.34 check inside of siw_main.c:siw_register_device()
around the use of ib_register_device().  In post v2.6.34 kernels this function accepts a second
parameter used a sysfs port callback described here:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=9a6edb60ec10d86b1025a0cdad68fd89f1ddaf02

This patch currently sets this second parameter to NULL.

Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>
---
 softiwarp/siw_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/softiwarp/siw_main.c b/softiwarp/siw_main.c
index cacedea..c97adee 100644
--- a/softiwarp/siw_main.c
+++ b/softiwarp/siw_main.c
@@ -233,8 +233,11 @@ int siw_register_device(struct siw_dev *dev)
 	ibdev->iwcm->add_ref = siw_qp_get_ref;
 	ibdev->iwcm->rem_ref = siw_qp_put_ref;
 	ibdev->iwcm->get_qp = siw_get_ofaqp;
-
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2, 6, 34)
+	rv = ib_register_device(ibdev, NULL);
+#else
 	rv = ib_register_device(ibdev);
+#endif
 	if (rv) {
 		dprint(DBG_DM|DBG_ON, "(dev=%s): "
 			"ib_register_device failed: rv=%d\n", ibdev->name, rv);
-- 
1.5.6.5
