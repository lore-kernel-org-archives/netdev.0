From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/4] isdn: accept CAPI Informational Info values as success
Date: Sat, 19 Sep 2009 01:57:42 +0200 (CEST)
Message-ID: <20090919-patch-capi-2.tilman@imap.cc>
References: <20090919-patch-capi-0.tilman@imap.cc>
Cc: davem@davemloft.net, i4ldeveloper@listserv.isdn4linux.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:35033 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317AbZIRX6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 19:58:16 -0400
In-Reply-To: <20090919-patch-capi-0.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Info values in the 0x00xx range are defined in the CAPI standard
as "Informational, message processed successfully". Therefore a
CONNECT_B3_CONF message with an Info value in that range should
open an NCCI just as with Info==0.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 2d83524..65bf91e 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -603,7 +603,7 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 
 	if (CAPIMSG_CMD(skb->data) == CAPI_CONNECT_B3_CONF) {
 		u16 info = CAPIMSG_U16(skb->data, 12); // Info field
-		if (info == 0) {
+		if ((info & 0xff00) == 0) {
 			mutex_lock(&cdev->ncci_list_mtx);
 			capincci_alloc(cdev, CAPIMSG_NCCI(skb->data));
 			mutex_unlock(&cdev->ncci_list_mtx);
-- 
1.6.2.1.214.ge986c

