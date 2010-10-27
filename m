From: Nelson Elhage <nelhage@ksplice.com>
Subject: [PATCH] pktgen: Remove a dangerous debug print.
Date: Wed, 27 Oct 2010 15:13:08 -0400
Message-ID: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eugene Teo <eugene@redhat.com>,
	Nelson Elhage <nelhage@ksplice.com>
To: Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-8.MIT.EDU ([18.7.68.37]:63025 "EHLO
	dmz-mailsec-scanner-8.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755385Ab0J0TTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:19:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were allocating an arbitrarily-large buffer on the stack, which would allow a
buggy or malicious userspace program to overflow the kernel stack.

Since the debug printk() was just printing exactly the text passed from
userspace, it's probably just as easy for anyone who might use it to augment (or
just strace(1)) the program writing to the pktgen file, so let's just not bother
trying to print the whole buffer.

Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
---
 net/core/pktgen.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 10a1ea7..de8e0da 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -888,14 +888,9 @@ static ssize_t pktgen_if_write(struct file *file,
 
 	i += len;
 
-	if (debug) {
-		char tb[count + 1];
-		if (copy_from_user(tb, user_buffer, count))
-			return -EFAULT;
-		tb[count] = 0;
-		printk(KERN_DEBUG "pktgen: %s,%lu  buffer -:%s:-\n", name,
-		       (unsigned long)count, tb);
-	}
+	if (debug)
+		printk(KERN_DEBUG "pktgen: %s,%lu\n", name,
+		       (unsigned long)count);
 
 	if (!strcmp(name, "min_pkt_size")) {
 		len = num_arg(&user_buffer[i], 10, &value);
-- 
1.7.1.31.g6297e

