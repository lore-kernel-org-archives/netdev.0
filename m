From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] net/act_pedit: fix an error code
Date: Wed, 14 Jun 2017 13:29:31 +0300
Message-ID: <20170614102930.GH29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33705 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdFNK3x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 06:29:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm reviewing static checker warnings where we do ERR_PTR(0), which is
the same as NULL.  I'm pretty sure we intended to return ERR_PTR(-EINVAL)
here.  Sometimes these bugs lead to a NULL dereference but I don't
immediately see that problem here.

Fixes: 71d0ed7079df ("net/act_pedit: Support using offset relative to the conventional network headers")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 164b5ac094be..7dc5892671c8 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -94,8 +94,10 @@ static struct tcf_pedit_key_ex *tcf_pedit_keys_ex_parse(struct nlattr *nla,
 		k++;
 	}
 
-	if (n)
+	if (n) {
+		err = -EINVAL;
 		goto err_out;
+	}
 
 	return keys_ex;
 
