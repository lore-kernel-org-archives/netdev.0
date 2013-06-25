From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v5 5/6] rtnetlink: allow using zero MAC address
 in rtnl_fdb_{add,del}
Date: Tue, 25 Jun 2013 09:37:38 -0700
Message-ID: <20130625093738.2b3e3a0b@nehalam.linuxnetplumber.net>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372165316-17647-6-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:54242 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771Ab3FYQhm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 12:37:42 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so1009259pdj.22
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 09:37:42 -0700 (PDT)
In-Reply-To: <1372165316-17647-6-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed, to avoid breaking bridge use of fdb.
I will just add it after Mike's patches.


>From 9d1cdde78c5973eeb0c80b5b053ea35e61005253 Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 25 Jun 2013 09:34:36 -0700
Subject: [PATCH] bridge: check for zero ether address in fdb add

The check for all-zero ether address was removed from rtnetlink core,
since Vxlan uses all-zero ether address to signify default address.
Need to add check back in for bridge.

Signed-off-by: Stephen Hemminber <stephen@networkplumber.org>
---
 net/bridge/br_fdb.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index ebfa444..60aca91 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -707,6 +707,11 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		}
 	}
 
+	if (is_zero_ether_addr(addr)) {
+		pr_info("bridge: RTM_NEWNEIGH with invalid ether address\n");
+		return -EINVAL;
+	}
+
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
-- 
1.7.10.4
