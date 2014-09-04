From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net-timestamp: fix allocation error in test
Date: Thu,  4 Sep 2014 10:15:45 -0400
Message-ID: <1409840145-32723-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, dborkman@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:60257 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaIDOPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:15:52 -0400
Received: by mail-pd0-f201.google.com with SMTP id v10so61081pde.2
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 07:15:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A buffer is incorrectly zeroed to the length of the pointer. If
cfg_payload_len < sizeof(void *) this can overwrites unrelated memory.
The buffer contents are never read, so no need to zero.

Fixes: 8fe2f761cae9 ("net-timestamp: expand documentation")

Reported-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/timestamping/txtimestamp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Documentation/networking/timestamping/txtimestamp.c
index e5b0b98..b32fc2a 100644
--- a/Documentation/networking/timestamping/txtimestamp.c
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -192,7 +192,6 @@ static int recv_errmsg(int fd)
 	memset(&msg, 0, sizeof(msg));
 	memset(&entry, 0, sizeof(entry));
 	memset(ctrl, 0, sizeof(ctrl));
-	memset(data, 0, sizeof(data));
 
 	entry.iov_base = data;
 	entry.iov_len = cfg_payload_len;
-- 
2.1.0.rc2.206.gedb03e5
