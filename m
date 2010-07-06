From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 09/11] isdn/gigaset: fix leaks in error path
Date: Tue,  6 Jul 2010 02:19:19 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-09.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Take care to free all previously allocated ressources in the
"out of memory" error path of the ISDN_CMD_DIAL branch.
Based on an original patch by Dan Carpenter.

Impact: bugfix
Reported-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Acked-by: Dan Carpenter <error27@gmail.com>
---
 drivers/isdn/gigaset/i4l.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 1d084bb..34bca37 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -419,6 +419,8 @@ oom:
 	dev_err(bcs->cs->dev, "out of memory\n");
 	for (i = 0; i < AT_NUM; ++i)
 		kfree(commands[i]);
+	kfree(commands);
+	gigaset_free_channel(bcs);
 	return -ENOMEM;
 }
 
-- 
1.6.5.3.298.g39add
