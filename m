From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 4/5] team: ab: walk through port list non-rcu
Date: Tue, 10 Apr 2012 17:15:45 +0200
Message-ID: <1334070946-7704-5-git-send-email-jpirko@redhat.com>
References: <1334070946-7704-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759317Ab2DJPP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 11:15:59 -0400
In-Reply-To: <1334070946-7704-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since team->lock is being held, _rcu variant make no sense.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team_mode_activebackup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 6cde1ab..a715c40 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -72,7 +72,7 @@ static int ab_active_port_set(struct team *team, struct team_gsetter_ctx *ctx)
 {
 	struct team_port *port;
 
-	list_for_each_entry_rcu(port, &team->port_list, list) {
+	list_for_each_entry(port, &team->port_list, list) {
 		if (port->dev->ifindex == ctx->data.u32_val) {
 			rcu_assign_pointer(ab_priv(team)->active_port, port);
 			return 0;
-- 
1.7.9.1
