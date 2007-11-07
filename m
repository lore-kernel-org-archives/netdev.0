From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH] netns: init dev_base_lock only once
Date: Wed, 7 Nov 2007 15:51:33 +0300
Message-ID: <20071107125133.GA6213@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devel@openvz.org, ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:9450 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbXKGMvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 07:51:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* it already statically initialized
* reinitializing live global spinlock every time netns is
  setup is also wrong

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/core/dev.c |    1 -
 1 file changed, 1 deletion(-)

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4330,7 +4330,6 @@ static struct hlist_head *netdev_create_hash(void)
 static int __net_init netdev_init(struct net *net)
 {
 	INIT_LIST_HEAD(&net->dev_base_head);
-	rwlock_init(&dev_base_lock);
 
 	net->dev_name_head = netdev_create_hash();
 	if (net->dev_name_head == NULL)

