From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH] bridge: fix "entering disabled state" logging
Date: Tue, 06 Mar 2012 16:22:19 +0200
Message-ID: <20120306142219.31783.30201.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49885 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030681Ab2CFOWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:22:24 -0500
Received: by eekc41 with SMTP id c41so1904503eek.19
        for <netdev@vger.kernel.org>; Tue, 06 Mar 2012 06:22:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we have:
eth0: link down
br0: port 1(eth0) entering forwarding state

State should be logged *after* it was changed, not before.

Reported-by: Zilvinas Valinskas <zilvinas@wilibox.com>
Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
---

 net/bridge/br_stp_if.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 19308e3..f494496 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -98,14 +98,13 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	struct net_bridge *br = p->br;
 	int wasroot;
 
-	br_log_state(p);
-
 	wasroot = br_is_root_bridge(br);
 	br_become_designated_port(p);
 	p->state = BR_STATE_DISABLED;
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
 
+	br_log_state(p);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	del_timer(&p->message_age_timer);
