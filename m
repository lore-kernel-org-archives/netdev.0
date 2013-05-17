From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] net: irda: using kzalloc() instead of kmalloc() to avoid
 strncpy() issue.
Date: Fri, 17 May 2013 17:13:04 +0800
Message-ID: <5195F4A0.3000708@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:46157 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab3EQJOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 05:14:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


'discovery->data.info' length is 22, NICKNAME_MAX_LEN is 21, so the
strncpy() will always left the last byte of 'discovery->data.info'
uninitialized.

When 'text' length is longer than 21 (NICKNAME_MAX_LEN), if still left
the last byte of 'discovery->data.info' uninitialized, the next
strlen() will cause issue.

Also 'discovery->data' is 'struct irda_device_info' which defined in
"include/uapi/...", it may copy to user mode, so need whole initialized.

All together, need use kzalloc() instead of kmalloc() to initialize all
members firstly.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/irda/irlap_frame.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 8c00416..9ea0c93 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -544,7 +544,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 		/*
 		 *  We now have some discovery info to deliver!
 		 */
-		discovery = kmalloc(sizeof(discovery_t), GFP_ATOMIC);
+		discovery = kzalloc(sizeof(discovery_t), GFP_ATOMIC);
 		if (!discovery) {
 			IRDA_WARNING("%s: unable to malloc!\n", __func__);
 			return;
-- 
1.7.7.6
