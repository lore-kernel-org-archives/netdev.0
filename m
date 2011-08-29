From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [PATCH] Always initialize fw_entry with NULL
Date: Mon, 29 Aug 2011 09:39:32 +0200
Message-ID: <201108290939.32243.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:52441 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014Ab1H2IAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 04:00:35 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id C87EC300D3
	for <netdev@vger.kernel.org>; Mon, 29 Aug 2011 09:39:33 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 90F672AC54
	for <netdev@vger.kernel.org>; Mon, 29 Aug 2011 09:39:33 +0200 (CEST)
Received: from storm.localnet (storm.m.i2n [172.16.1.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: smtp-auth-user)
	by intranator.m.i2n (Postfix) with ESMTPSA id A25342AC52
	for <netdev@vger.kernel.org>; Mon, 29 Aug 2011 09:39:32 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise the exit code path might try to release
a non-existing firmware object on an error condition.

Issue detected by cppcheck.

Resending to netdev as orionco-devel seems to be sleeping.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 drivers/net/wireless/orinoco/orinoco_usb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c 
b/drivers/net/wireless/orinoco/orinoco_usb.c
index 811e87f..973a55f 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -1579,7 +1579,7 @@ static int ezusb_probe(struct usb_interface 
*interface,
 	struct ezusb_priv *upriv = NULL;
 	struct usb_interface_descriptor *iface_desc;
 	struct usb_endpoint_descriptor *ep;
-	const struct firmware *fw_entry;
+	const struct firmware *fw_entry = NULL;
 	int retval = 0;
 	int i;
 
-- 
1.7.4.4
