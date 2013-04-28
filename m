From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: PATCH iproute2] catch iptables interface changes
Date: Sun, 28 Apr 2013 10:44:38 -0400
Message-ID: <517D35D6.8090606@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050306030203050200040804"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@inai.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f176.google.com ([209.85.210.176]:41760 "EHLO
	mail-ia0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227Ab3D1Oon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 10:44:43 -0400
Received: by mail-ia0-f176.google.com with SMTP id l27so4361699iae.7
        for <netdev@vger.kernel.org>; Sun, 28 Apr 2013 07:44:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050306030203050200040804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Thanks to Jan for this suggestion.
Hopefully this would ease some of the pain.

cheers,
jamal

--------------050306030203050200040804
Content-Type: text/plain; charset=UTF-8;
 name="catch-ipt-upgrade"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="catch-ipt-upgrade"

commit ba9b18dbcad853e22ea2b8ecf87d53ef2f6cf58c
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Sun Apr 28 07:41:47 2013 -0400

    Detect future iptable changes interfaces earlier in the dev
    cycles. Hopefully someone is going to complain about such breakage
    and we'll get the fix in sooner.
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 3edf520..b266337 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -129,6 +129,10 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 	__u32 hook = 0, index = 0;
 	struct option *opts = NULL;
 
+#if (XTABLES_VERSION_CODE > 7)
+#error Someone call the guy who changed xtables ver 7 and \
+	make him fix it^W^W^W^W say you need help.
+#endif
 	xtables_init_all(&tcipt_globals, NFPROTO_IPV4);
 	set_lib_dir();
 

--------------050306030203050200040804--
