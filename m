From: akpm@linux-foundation.org
Subject: [patch 10/18] ax88796 printk fixes
Date: Fri, 10 Aug 2007 14:05:21 -0700
Message-ID: <200708102105.l7AL5Lxg008974@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59912 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934600AbXHJVPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:15:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/ax88796.c: In function `ax_probe':
drivers/net/ax88796.c:825: warning: size_t format, different type arg (arg 4)
drivers/net/ax88796.c:825: warning: size_t format, different type arg (arg 5)

resource_size_t isn't size_t.

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ax88796.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -puN drivers/net/ax88796.c~ax88796-printk-fixes drivers/net/ax88796.c
--- a/drivers/net/ax88796.c~ax88796-printk-fixes
+++ a/drivers/net/ax88796.c
@@ -821,8 +821,9 @@ static int ax_probe(struct platform_devi
 	dev->base_addr = (unsigned long)ei_status.mem;
 
 	if (ei_status.mem == NULL) {
-		dev_err(&pdev->dev, "Cannot ioremap area (%08zx,%08zx)\n",
-			res->start, res->end);
+		dev_err(&pdev->dev, "Cannot ioremap area (%08llx,%08llx)\n",
+			(unsigned long long)res->start,
+			(unsigned long long)res->end);
 
  		ret = -ENXIO;
 		goto exit_req;
_
