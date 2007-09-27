From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] proper comment for loopback initialization order
Date: Thu, 27 Sep 2007 16:25:27 +0400
Message-ID: <20070927122527.GA10972@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvz.org, devel@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:55280 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751273AbXI0MYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 08:24:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Loopback device is special. It should be initialized at the very
beginning.  Initialization order has been changed by
Eric W. Biederman <ebiederm@xmission.com> and this change is non-obvious
and important enough to add proper comment.

Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./drivers/net/loopback.c.loopcomment	2007-08-26 19:30:38.000000000 +0400
+++ ./drivers/net/loopback.c	2007-09-27 16:08:06.000000000 +0400
@@ -293,4 +293,6 @@ static int __init loopback_init(void)
 	return register_pernet_device(&loopback_net_ops);
 }
 
+/* Loopback is special. It should be initialized before any other network
+   device and network subsystem */
 fs_initcall(loopback_init);
