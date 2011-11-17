From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next] team: replace kmalloc+memcpy by kmemdup
Date: Thu, 17 Nov 2011 17:32:37 +0100
Message-ID: <1321547557-1175-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932294Ab1KQQcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 11:32:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index c48ef19..064155d 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -104,19 +104,15 @@ int team_options_register(struct team *team,
 	if (!dst_opts)
 		return -ENOMEM;
 	for (i = 0; i < option_count; i++, option++) {
-		struct team_option *dst_opt;
-
 		if (__team_find_option(team, option->name)) {
 			err = -EEXIST;
 			goto rollback;
 		}
-		dst_opt = kmalloc(sizeof(*option), GFP_KERNEL);
-		if (!dst_opt) {
+		dst_opts[i] = kmemdup(option, sizeof(*option), GFP_KERNEL);
+		if (!dst_opts[i]) {
 			err = -ENOMEM;
 			goto rollback;
 		}
-		memcpy(dst_opt, option, sizeof(*option));
-		dst_opts[i] = dst_opt;
 	}
 
 	for (i = 0; i < option_count; i++)
-- 
1.7.6
