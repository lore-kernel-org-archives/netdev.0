From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/8] gigaset: fix possible oops in error handling
Date: Thu, 14 May 2009 00:44:17 +0200 (CEST)
Message-ID: <20090514-patch-02.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:38976 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754942AbZEMWod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:33 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pr_warning() / pr_err() instead of dev_warn() / dev_err() in two
places where the dev pointer isn't guaranteed to be valid.

Impact: error handling bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/interface.c |    3 +--
 drivers/isdn/gigaset/proc.c      |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 820a309..5a8e259 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -599,8 +599,7 @@ void gigaset_if_init(struct cardstate *cs)
 	if (!IS_ERR(cs->tty_dev))
 		dev_set_drvdata(cs->tty_dev, cs);
 	else {
-		dev_warn(cs->dev,
-			 "could not register device to the tty subsystem\n");
+		pr_warning("could not register device to the tty subsystem\n");
 		cs->tty_dev = NULL;
 	}
 	mutex_unlock(&cs->mutex);
diff --git a/drivers/isdn/gigaset/proc.c b/drivers/isdn/gigaset/proc.c
index da6f3ac..9715aad 100644
--- a/drivers/isdn/gigaset/proc.c
+++ b/drivers/isdn/gigaset/proc.c
@@ -79,5 +79,5 @@ void gigaset_init_dev_sysfs(struct cardstate *cs)
 
 	gig_dbg(DEBUG_INIT, "setting up sysfs");
 	if (device_create_file(cs->tty_dev, &dev_attr_cidmode))
-		dev_err(cs->dev, "could not create sysfs attribute\n");
+		pr_err("could not create sysfs attribute\n");
 }
-- 
1.6.2.1.214.ge986c

