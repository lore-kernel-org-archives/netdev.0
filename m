From: Ahmad Fatoum <ahmad@a3f.at>
Subject: [PATCH] net-next: Fix minor code bug in timestamping.txt
Date: Sat,  8 Jul 2017 21:28:44 +0200
Message-ID: <20170708192844.70105-1-ahmad@a3f.at>
Cc: Ahmad Fatoum <ahmad@a3f.at>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:47759 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752993AbdGHTms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 15:42:48 -0400
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id EFDBC47B217
        for <netdev@vger.kernel.org>; Sat,  8 Jul 2017 21:35:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passing (void*)val instead of &val would make a pointer out of an integer
and cause sock_setsockopt to -EFAULT.

See tools/testing/selftests/networking/timestamping/timestamping.c
for a working example.

Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Ahmad Fatoum <ahmad@a3f.at>
---
 Documentation/networking/timestamping.txt | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 196ba17cc344..1be0b6f9e0cb 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -44,8 +44,7 @@ timeval of SO_TIMESTAMP (ms).
 Supports multiple types of timestamp requests. As a result, this
 socket option takes a bitmap of flags, not a boolean. In
 
-  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, (void *) val,
-                   sizeof(val));
+  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, &val, sizeof(val));
 
 val is an integer with any of the following bits set. Setting other
 bit returns EINVAL and does not change the current state.
@@ -249,8 +248,7 @@ setsockopt to receive timestamps:
 
   __u32 val = SOF_TIMESTAMPING_SOFTWARE |
 	      SOF_TIMESTAMPING_OPT_ID /* or any other flag */;
-  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, (void *) val,
-                   sizeof(val));
+  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, &val, sizeof(val));
 
 
 1.4 Bytestream Timestamps
-- 
2.13.2
