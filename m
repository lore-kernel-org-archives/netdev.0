From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] dev_change_name: ignore changes to same name
Date: Wed, 24 Oct 2007 06:44:45 -0700
Message-ID: <20071024064445.52b1e84e@shemminger-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56360 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752624AbXJXNo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 09:44:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prevent error/backtrace from dev_rename() when changing
name of network device to the same name. This is a common
situation with udev and other scripts that bind addr to device.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/core/dev.c	2007-10-24 06:01:31.000000000 -0700
+++ b/net/core/dev.c	2007-10-24 06:41:18.000000000 -0700
@@ -885,6 +885,9 @@ int dev_change_name(struct net_device *d
 	if (!dev_valid_name(newname))
 		return -EINVAL;
 
+	if (strncmp(newname, dev->name, IFNAMSIZ) == 0)
+		return 0;
+
 	memcpy(oldname, dev->name, IFNAMSIZ);
 
 	if (strchr(newname, '%')) {
