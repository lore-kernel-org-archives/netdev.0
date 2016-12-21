From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: Re: [PATCH 2/2] net: wireless: fix to uses struct
Date: Thu, 22 Dec 2016 01:01:44 +0200
Message-ID: <532551482361304@web26g.yandex.ru>
References: <608881482358981@web17g.yandex.ru> <1482359625.28171.2.camel@tiscali.nl> <601101482360611@web25o.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>,
        johannes <johannes@sipsolutions.net>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <601101482360611@web25o.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


My previous patch is invalid, I'm sorry.
The last patc will be fellow because "regulatory_request" is defined as a "static struct".

Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
---
 net/wireless/reg.c  | 10 +++++-----
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 5dbac37..5b70970 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -490,7 +490,7 @@ static int reg_query_builtin(const char *alpha2)
 	if (!regdom)
 		return -ENODATA;
 
-	request = kzalloc(sizeof(struct reg_regdb_apply_request), GFP_KERNEL);
+	request = kzalloc(sizeof(*reg_regdb_apply_request), GFP_KERNEL);
 	if (!request)
 		return -ENOMEM;

@@ -2661,7 +2661,7 @@ int regulatory_hint_found_beacon(struct wiphy *wiphy,
 	if (processing)
 		return 0;
 
-	reg_beacon = kzalloc(sizeof(struct reg_beacon), gfp);
+	reg_beacon = kzalloc(sizeof(*reg_beacon), gfp);
 	if (!reg_beacon)
 		return -ENOMEM;
 
-- 
2.1.4
