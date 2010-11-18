From: Daniel Turull <daniel.turull@gmail.com>
Subject: [PATH] dev: reusing unregistered ifindex values in net_device
Date: Thu, 18 Nov 2010 16:25:54 +0100
Message-ID: <AANLkTinx6Ww4ZwRUTyYD_STPSRsSFck8O=W5yeJSbBs_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Voravit T." <voravit@kth.se>, Robert Olsson <robert@herjulf.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41553 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749Ab0KRP0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 10:26:15 -0500
Received: by fxm10 with SMTP id 10so15624fxm.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 07:26:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a new index is going to be assigned in register_netdevice,
the dev_new_index starts to search possible values from the last index
given to a device although there might be some free ifindex that has been
previously unregistered.  This behaviour may create gap(s) in the ifindex list.

This patch checks for unused values from 1 and gives to the new device the
first available value. This limits the maximum ifindex to a smaller value.

The ifindex will still be unique since the old value is no longer in use.

Reported-by: Voravit Tanyingyong  <voravit@kth.se>
Signed-off-by: Daniel Turull <daniel.turull@gmail.com>

---
diff --git a/net/core/dev.c b/net/core/dev.c
index 381b8e2..a7babab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4871,7 +4871,7 @@ int dev_ioctl(struct net *net, unsigned int cmd,
void __user *arg)
  */
 static int dev_new_index(struct net *net)
 {
-	static int ifindex;
+	int ifindex;
 	for (;;) {
 		if (++ifindex <= 0)
 			ifindex = 1;
