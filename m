From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH 2/4] slip: fix MTU comparation operation when reallocating buffers
Date: Wed, 13 Jul 2011 11:46:17 +0400
Message-ID: <CAKh5nabAU=nYJdcbM55J=FDhcrZgW4G+vOBuOjT8TwniT457Jg@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: matvejchikov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42285 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965002Ab1GMHqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 03:46:37 -0400
Received: by qwk3 with SMTP id 3so2732125qwk.19
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 00:46:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sl_realloc_bufs() there is no reason to check if the requested MTU greater
than or equal to the current MTU value as this function called only
when requested
MTU not equals to the current value. So, the ">=" operation can be
safely replaced
with the ">".

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index e8c4582..d724d47 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -247,7 +247,7 @@ static int sl_realloc_bufs(struct slip *sl, int mtu)
 #else
 	if (xbuff == NULL || rbuff == NULL)  {
 #endif
-		if (mtu >= sl->mtu) {
+		if (mtu > sl->mtu) {
 			printk(KERN_WARNING "%s: unable to grow slip buffers, MTU change
cancelled.\n",
 			       dev->name);
 			err = -ENOBUFS;
-- 
1.7.6
