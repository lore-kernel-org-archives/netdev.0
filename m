From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH ] net_sched:  actions - Add default lookup
Date: Wed, 30 Oct 2013 07:25:41 -0400
Message-ID: <5270ECB5.2030601@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060302090609030100090903"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:42007 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab3J3LZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 07:25:50 -0400
Received: by mail-ie0-f175.google.com with SMTP id aq17so2014710iec.34
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 04:25:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060302090609030100090903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Attached. Tested with simple action.

cheers,
jamal

--------------060302090609030100090903
Content-Type: text/plain; charset=us-ascii;
 name="p1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="p1"

commit 80f80120ba4b85daf00c53eceebe7f0ad0b58a57
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Wed Oct 30 07:03:55 2013 -0400

    Provide default lookup function for actions that dont provide one
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fd70728..3c974a0 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -279,6 +279,10 @@ int tcf_register_action(struct tc_action_ops *act)
 	}
 	act->next = NULL;
 	*ap = act;
+
+	if (!act->lookup)
+		act->lookup = tcf_hash_search;
+
 	write_unlock(&act_mod_lock);
 	return 0;
 }

--------------060302090609030100090903--
