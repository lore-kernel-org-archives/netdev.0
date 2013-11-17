From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH ] net_sched: actions - Add default lookup
Date: Sun, 17 Nov 2013 11:23:10 -0500
Message-ID: <5288ED6E.8080008@mojatatu.com>
References: <5270ECB5.2030601@mojatatu.com>	<1383141605.4857.38.camel@edumazet-glaptop.roam.corp.google.com>	<20131103.231232.1438716028901698864.davem@davemloft.net> <20131103.231729.12647956618590906.davem@davemloft.net> <5288E4C2.9090405@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060603080501000204070309"
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:54453 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab3KQQXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 11:23:15 -0500
Received: by mail-ie0-f176.google.com with SMTP id x13so7621190ief.35
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 08:23:14 -0800 (PST)
In-Reply-To: <5288E4C2.9090405@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060603080501000204070309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Follow up to that patch would be this one.

I also want to do the same for the walker, but will wait
response.

cheers,
jamal

On 11/17/13 10:46, Jamal Hadi Salim wrote:
> On 11/03/13 23:17, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Sun, 03 Nov 2013 23:12:32 -0500 (EST)
>>
>>> Right, and BUG() if we try to register and action with a NULL .lookup
>>> member.
>>
>> I return an error, BUG() is too harsh.
>>
>
> Sorry - I was distracted, but have time now.
> I wanted to fix this then send the other patches - but confused.
> We are setting the default if someone registers an action with
> a NULL .lookup. Why do we want to return an error?
>
> cheers,
> jamal
>


--------------060603080501000204070309
Content-Type: text/plain; charset=us-ascii;
 name="p-act2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="p-act2"

commit 926db1197d055ee933265ad4d5f5ae2392bcc654
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Sun Nov 17 11:20:16 2013 -0500

    Use default lookup functions. Users are free to override when needed.
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 3a4c0ca..4225a93 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -585,7 +585,6 @@ static struct tc_action_ops act_csum_ops = {
 	.act		= tcf_csum,
 	.dump		= tcf_csum_dump,
 	.cleanup	= tcf_csum_cleanup,
-	.lookup		= tcf_hash_search,
 	.init		= tcf_csum_init,
 	.walk		= tcf_generic_walker
 };
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index fd2b3cf..15851da 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -206,7 +206,6 @@ static struct tc_action_ops act_gact_ops = {
 	.act		=	tcf_gact,
 	.dump		=	tcf_gact_dump,
 	.cleanup	=	tcf_gact_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_gact_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 60d88b6..1d3e191 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -298,7 +298,6 @@ static struct tc_action_ops act_ipt_ops = {
 	.act		=	tcf_ipt,
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_ipt_init,
 	.walk		=	tcf_generic_walker
 };
@@ -312,7 +311,6 @@ static struct tc_action_ops act_xt_ops = {
 	.act		=	tcf_ipt,
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_ipt_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 977c10e..6cb16ec 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -271,7 +271,6 @@ static struct tc_action_ops act_mirred_ops = {
 	.act		=	tcf_mirred,
 	.dump		=	tcf_mirred_dump,
 	.cleanup	=	tcf_mirred_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_mirred_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 876f0ef..30c13de 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -308,7 +308,6 @@ static struct tc_action_ops act_nat_ops = {
 	.act		=	tcf_nat,
 	.dump		=	tcf_nat_dump,
 	.cleanup	=	tcf_nat_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_nat_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 7ed78c9..ab4fc56 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -243,7 +243,6 @@ static struct tc_action_ops act_pedit_ops = {
 	.act		=	tcf_pedit,
 	.dump		=	tcf_pedit_dump,
 	.cleanup	=	tcf_pedit_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_pedit_init,
 	.walk		=	tcf_generic_walker
 };
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 272d8e9..16a62c3 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -407,7 +407,6 @@ static struct tc_action_ops act_police_ops = {
 	.act		=	tcf_act_police,
 	.dump		=	tcf_act_police_dump,
 	.cleanup	=	tcf_act_police_cleanup,
-	.lookup		=	tcf_hash_search,
 	.init		=	tcf_act_police_locate,
 	.walk		=	tcf_act_police_walker
 };

--------------060603080501000204070309--
