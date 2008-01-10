From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 2/6][NETNS]: Make the __addrconf_sysctl_register
 return an error
Date: Thu, 10 Jan 2008 17:01:13 +0300
Message-ID: <47862529.60209@openvz.org>
References: <478623C0.7030008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37064 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbYAJOBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 09:01:48 -0500
In-Reply-To: <478623C0.7030008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This error code will be needed to abort the namespace
creation if needed.

Probably, this is to be checked when a new device is
created (currently it is ignored).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/addrconf.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 27b35dd..18d4334 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4044,7 +4044,7 @@ static struct addrconf_sysctl_table
 	},
 };
 
-static void __addrconf_sysctl_register(char *dev_name, int ctl_name,
+static int __addrconf_sysctl_register(char *dev_name, int ctl_name,
 		struct inet6_dev *idev, struct ipv6_devconf *p)
 {
 	int i;
@@ -4088,14 +4088,14 @@ static void __addrconf_sysctl_register(char *dev_name, int ctl_name,
 		goto free_procname;
 
 	p->sysctl = t;
-	return;
+	return 0;
 
 free_procname:
 	kfree(t->dev_name);
 free:
 	kfree(t);
 out:
-	return;
+	return -ENOBUFS;
 }
 
 static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
-- 
1.5.3.4


