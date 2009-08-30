From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 25/47] Bluetooth: Coding style cleanup from previous rfcomm_init bug fix
Date: Sun, 30 Aug 2009 01:50:39 -0700
Message-ID: <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53304 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbZH3IwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:20 -0400
In-Reply-To: <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rfcomm_init bug fix went into the kernel premature before it got fully
reviewed and acknowledged by the Bluetooth maintainer. So fix up the coding
style now.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/rfcomm/core.c |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 94b3388..26af485 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -2080,7 +2080,7 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, rfcomm_dlc_sysfs_show, NULL);
 /* ---- Initialization ---- */
 static int __init rfcomm_init(void)
 {
-	int ret;
+	int err;
 
 	l2cap_load();
 
@@ -2088,33 +2088,35 @@ static int __init rfcomm_init(void)
 
 	rfcomm_thread = kthread_run(rfcomm_run, NULL, "krfcommd");
 	if (IS_ERR(rfcomm_thread)) {
-		ret = PTR_ERR(rfcomm_thread);
-		goto out_thread;
+		err = PTR_ERR(rfcomm_thread);
+		goto unregister;
 	}
 
 	if (class_create_file(bt_class, &class_attr_rfcomm_dlc) < 0)
 		BT_ERR("Failed to create RFCOMM info file");
 
-	ret = rfcomm_init_ttys();
-	if (ret)
-		goto out_tty;
+	err = rfcomm_init_ttys();
+	if (err < 0)
+		goto stop;
 
-	ret = rfcomm_init_sockets();
-	if (ret)
-		goto out_sock;
+	err = rfcomm_init_sockets();
+	if (err < 0)
+		goto cleanup;
 
 	BT_INFO("RFCOMM ver %s", VERSION);
 
 	return 0;
 
-out_sock:
+cleanup:
 	rfcomm_cleanup_ttys();
-out_tty:
+
+stop:
 	kthread_stop(rfcomm_thread);
-out_thread:
+
+unregister:
 	hci_unregister_cb(&rfcomm_cb);
 
-	return ret;
+	return err;
 }
 
 static void __exit rfcomm_exit(void)
-- 
1.6.2.5

