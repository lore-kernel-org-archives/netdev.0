From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: [PATCH] netns: remove useless synchronize_net()
Date: Thu, 05 Feb 2009 11:21:22 +0100
Message-ID: <498ABDA2.5040603@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010509040006010803040600"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:59836 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632AbZBEKVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2009 05:21:33 -0500
Received: from smtp4-g21.free.fr (localhost [127.0.0.1])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 070764C818C
	for <netdev@vger.kernel.org>; Thu,  5 Feb 2009 11:21:26 +0100 (CET)
Received: from [192.168.1.1] (shm67-6-88-178-145-40.fbx.proxad.net [88.178.145.40])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 141F34C8143
	for <netdev@vger.kernel.org>; Thu,  5 Feb 2009 11:21:24 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010509040006010803040600
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

In dev_change_net_namespace(), synchronize_net() is called at the end of the 
function, but there is no reason (no deletion occurs).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

--------------010509040006010803040600
Content-Type: text/x-patch;
 name="y.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="y.diff"

--- linux-2.6.28.2/net/core/dev.c	2009-01-24 19:42:07.000000000 -0500
+++ linux-2.6.28.2-new/net/core/dev.c	2009-02-05 04:16:35.000000000 -0500
@@ -4546,7 +4546,6 @@ int dev_change_net_namespace(struct net_
 	/* Notify protocols, that a new device appeared. */
 	call_netdevice_notifiers(NETDEV_REGISTER, dev);
 
-	synchronize_net();
 	err = 0;
 out:
 	return err;

--------------010509040006010803040600--
