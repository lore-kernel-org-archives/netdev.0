From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 2/6] mISDN: Fix overlapping data access
Date: Tue, 2 Jun 2009 15:37:37 +0200
Message-ID: <1ce1513f48e3bc4d55ee672f0e39f5063a02ab7a.1244739994.git.keil@b1-systems.de>
References: <cover.1244739994.git.keil@b1-systems.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from d112a2.x-mailer.de ([212.162.53.4]:33209 "EHLO
	d112a2.x-mailer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbZFKR2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 13:28:31 -0400
In-Reply-To: <cover.1244739994.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove code rewriting a buffer by itself.
This fix bug 12970 on bugzilla.kernel.org.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/dsp_pipeline.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_pipeline.c b/drivers/isdn/mISDN/dsp_pipeline.c
index ac61f19..e994167 100644
--- a/drivers/isdn/mISDN/dsp_pipeline.c
+++ b/drivers/isdn/mISDN/dsp_pipeline.c
@@ -55,20 +55,19 @@ static ssize_t
 attr_show_args(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct mISDN_dsp_element *elem = dev_get_drvdata(dev);
-	ssize_t len = 0;
-	int i = 0;
+	int i;
+	char *p = buf;
 
 	*buf = 0;
-	for (; i < elem->num_args; ++i)
-		len = sprintf(buf, "%sName:        %s\n%s%s%sDescription: %s\n"
-			"\n", buf,
+	for (i = 0; i < elem->num_args; i++)
+		p += sprintf(p, "Name:        %s\n%s%s%sDescription: %s\n\n",
 			  elem->args[i].name,
 			  elem->args[i].def ? "Default:     " : "",
 			  elem->args[i].def ? elem->args[i].def : "",
 			  elem->args[i].def ? "\n" : "",
 			  elem->args[i].desc);
 
-	return len;
+	return p - buf;
 }
 
 static struct device_attribute element_attributes[] = {
-- 
1.6.0.2

