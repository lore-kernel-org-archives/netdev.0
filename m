From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bridge: fix accidental creation of sysfs directory
Date: Sat, 16 Apr 2011 09:09:15 -0700
Message-ID: <20110416090915.2594a78e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57167 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611Ab1DPQJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 12:09:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bb900b27a2f49b37bc38c08e656ea13048fee13b introduced a bug in net-next
because of a typo in notifier. Every device would have the sysfs
bridge directory (and files). 

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_notify.c	2011-04-16 08:56:06.130218417 -0700
+++ b/net/bridge/br_notify.c	2011-04-16 08:59:30.703509541 -0700
@@ -37,7 +37,7 @@ static int br_device_event(struct notifi
 	int err;
 
 	/* register of bridge completed, add sysfs entries */
-	if ((dev->priv_flags && IFF_EBRIDGE) && event == NETDEV_REGISTER) {
+	if ((dev->priv_flags & IFF_EBRIDGE) && event == NETDEV_REGISTER) {
 		br_sysfs_addbr(dev);
 		return NOTIFY_DONE;
 	}
