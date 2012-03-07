From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH 2/2] bridge: fix state reporting when port is disabled
Date: Wed, 07 Mar 2012 10:25:22 +0200
Message-ID: <20120307082522.6293.26893.stgit@localhost.localdomain>
References: <20120307082514.6293.59158.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:60550 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753282Ab2CGIZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 03:25:26 -0500
Received: by mail-lpp01m010-f46.google.com with SMTP id j13so6990395lah.19
        for <netdev@vger.kernel.org>; Wed, 07 Mar 2012 00:25:25 -0800 (PST)
In-Reply-To: <20120307082514.6293.59158.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we have:
eth0: link *down*
br0: port 1(eth0) entered *forwarding* state

br_log_state(p) should be called *after* p->state is set
to BR_STATE_DISABLED.

Reported-by: Zilvinas Valinskas <zilvinas@wilibox.com>
Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
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
