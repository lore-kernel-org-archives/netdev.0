From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/4] batman-adv: check proto length before accessing proto string buffer
Date: Thu,  9 May 2013 12:56:44 +0200
Message-ID: <1368097007-817-2-git-send-email-ordex@autistici.org>
References: <1368097007-817-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:44779 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab3EIK6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 06:58:34 -0400
In-Reply-To: <1368097007-817-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

batadv_param_set_ra() strips the trailing '\n' from the supplied
string buffer without checking the length of the buffer first. This
patches avoids random memory access and associated potential
crashes.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 3e30a0f..9c620cd 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -475,7 +475,7 @@ static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 	char *algo_name = (char *)val;
 	size_t name_len = strlen(algo_name);
 
-	if (algo_name[name_len - 1] == '\n')
+	if (name_len > 0 && algo_name[name_len - 1] == '\n')
 		algo_name[name_len - 1] = '\0';
 
 	bat_algo_ops = batadv_algo_get(algo_name);
-- 
1.8.1.5
