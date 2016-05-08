From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] tc fix ife late binding
Date: Sun,  8 May 2016 11:28:49 -0400
Message-ID: <1462721329-27987-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34150 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbcEHP26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 11:28:58 -0400
Received: by mail-io0-f193.google.com with SMTP id d62so16773142iof.1
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 08:28:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

following late action binding didn't work:

sudo tc actions add action ife encode \
type 0xDEAD allow mark dst 02:15:15:15:15:15 index 1

sudo tc filter add dev lo parent ffff: protocol ip prio 2 u32\
match ip src 127.0.0.2/32 flowid 1:2 action ife index 1

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_ife.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index ed01ff7..c8ae04d 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -182,6 +182,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 				fprintf(stderr, "ife: Illegal \"index\"\n");
 				return -1;
 			}
+			ok++;
 			argc--;
 			argv++;
 		}
-- 
1.9.1
