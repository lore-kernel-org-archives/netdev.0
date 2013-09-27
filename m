From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] qdisc: basic classifier - remove unnecessary
 initialization
Date: Thu, 26 Sep 2013 17:42:16 -0700
Message-ID: <20130926174216.447555bd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:63367 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab3I0AmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 20:42:19 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so2045660pab.32
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 17:42:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

err is set once, then first code resets it.
  err = tcf_exts_validate(...)

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/sched/cls_basic.c	2013-08-10 10:36:11.657498301 -0700
+++ b/net/sched/cls_basic.c	2013-09-05 18:05:14.718200833 -0700
@@ -137,7 +137,7 @@ static int basic_set_parms(struct net *n
 			   struct nlattr **tb,
 			   struct nlattr *est)
 {
-	int err = -EINVAL;
+	int err;
 	struct tcf_exts e;
 	struct tcf_ematch_tree t;
 
