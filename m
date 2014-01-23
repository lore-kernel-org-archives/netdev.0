From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH stable 3.7+] fib_frontend: fix possible NULL pointer dereference
Date: Thu, 23 Jan 2014 10:19:34 +0100
Message-ID: <52E0DEA6.3060803@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:24674 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaAWJTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 04:19:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The two commits 0115e8e30d (net: remove delay at device dismantle) and
748e2d9396a (net: reinstate rtnl in call_netdevice_notifiers()) silently
removed a NULL pointer check for in_dev since Linux 3.7.

This patch re-introduces this check as it causes crashing the kernel when
setting small mtu values on non-ip capable netdevices.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d846304..c7539e2 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1047,6 +1047,8 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	}
 
 	in_dev = __in_dev_get_rtnl(dev);
+	if (!in_dev)
+		return NOTIFY_DONE;
 
 	switch (event) {
 	case NETDEV_UP:
