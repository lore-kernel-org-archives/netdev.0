From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH 3/4] slip: remove redundant check slip_devs for NULL
Date: Wed, 13 Jul 2011 11:46:57 +0400
Message-ID: <CAKh5naa_ARaJvZFOMva9V22YCTkVyPMw1+-x=GTtx-niwpOFSg@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: matvejchikov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:33899 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758678Ab1GMHrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 03:47:17 -0400
Received: by qwk3 with SMTP id 3so2732338qwk.19
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 00:47:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As slip_devs is initialized on module load stage there is no reason to
check it for NULL anywhere instead of the deinitialization routine because
if we can't get enough memory on startup we don't run at all.

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index d724d47..6f97c59 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -726,9 +726,6 @@ static struct slip *sl_alloc(dev_t line)
 	struct net_device *dev = NULL;
 	struct slip       *sl;

-	if (slip_devs == NULL)
-		return NULL;	/* Master array missing ! */
-
 	for (i = 0; i < slip_maxdev; i++) {
 		dev = slip_devs[i];
 		if (dev == NULL)
-- 
1.7.6
