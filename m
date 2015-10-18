From: Gao feng <omarapazanadi@gmail.com>
Subject: [PATCH] vsock: fix missing cleanup when misc_register failed
Date: Sun, 18 Oct 2015 21:53:11 +0800
Message-ID: <1445176391-8730-1-git-send-email-omarapazanadi@gmail.com>
Cc: Gao feng <omarapazanadi@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36790 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbbJRNxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 09:53:20 -0400
Received: by pacfv9 with SMTP id fv9so67351779pac.3
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 06:53:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reset transport and unlock if misc_register failed.

Signed-off-by: Gao feng <omarapazanadi@gmail.com>
---
 net/vmw_vsock/af_vsock.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index df5fc6b..5f5fbed 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1948,7 +1948,7 @@ int __vsock_core_init(const struct vsock_transport *t, struct module *owner)
 	err = misc_register(&vsock_device);
 	if (err) {
 		pr_err("Failed to register misc device\n");
-		return -ENOENT;
+		goto err_reset_transport;
 	}
 
 	err = proto_register(&vsock_proto, 1);	/* we want our slab */
@@ -1969,8 +1969,9 @@ int __vsock_core_init(const struct vsock_transport *t, struct module *owner)
 
 err_unregister_proto:
 	proto_unregister(&vsock_proto);
-err_misc_deregister:
+err_unregister_misc:
 	misc_deregister(&vsock_device);
+err_reset_transport:
 	transport = NULL;
 err_busy:
 	mutex_unlock(&vsock_register_mutex);
-- 
2.4.3
