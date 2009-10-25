From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Sun, 25 Oct 2009 21:58:53 +0200
Message-ID: <200910252158.53921.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_93K5KtoEllBzRnC"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12065 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753599AbZJYUCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 16:02:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_93K5KtoEllBzRnC
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit


The current dev_name_hash is not very good at spreading entries when a
large number of interfaces of the same type (e.g. ethXXXXX) are used.

Here are some performance numbers for creating 16000 dummy interfaces with
and without the patch (with per device sysctl entries disabled)

    With patch                      Without patch

    real    0m 2.27s                real    0m 4.32s
    user    0m 0.00s                user    0m 0.00s
    sys     0m 1.13s                sys     0m 2.16s

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/dev.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

--Boundary-00=_93K5KtoEllBzRnC
Content-Type: text/x-patch;
  charset="utf-8";
  name="5504c10b4f96275a4b60d0705f71614b6eba6b5c.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="5504c10b4f96275a4b60d0705f71614b6eba6b5c.diff"

diff --git a/net/core/dev.c b/net/core/dev.c
index fa88dcd..af3cab3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -198,7 +198,13 @@ EXPORT_SYMBOL(dev_base_lock);
 
 static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
 {
-	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
+	unsigned hash = 0;
+	int len = strnlen(name, IFNAMSIZ);
+	int i;
+
+	for (i = 0; i < len; ++i)
+		hash = 31 * hash + name[i];
+
 	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
 }
 

--Boundary-00=_93K5KtoEllBzRnC--


