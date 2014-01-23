From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 3/6] net_sched: act: hide struct tcf_common from API
Date: Thu, 23 Jan 2014 13:37:11 -0800
Message-ID: <CAM_iQpVMedBmV1t3SrxifuXhtrZJAxtn1wm1xSnGpZNb=BfdNg@mail.gmail.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389987427-14085-4-git-send-email-xiyou.wangcong@gmail.com>
	<52DD1E15.2040400@mojatatu.com>
	<52DFBD40.4090905@mojatatu.com>
	<CAM_iQpXRyQibP7+Zbxgpie7AfEAxZamZ6wSWDrnQbweRJEmnrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:64226 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaAWVhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:37:12 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so2865584oag.0
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 13:37:11 -0800 (PST)
In-Reply-To: <CAM_iQpXRyQibP7+Zbxgpie7AfEAxZamZ6wSWDrnQbweRJEmnrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 11:10 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> Hi, Jamal
>
> I had similar tests locally, I will check why the first of your test
> failed tomorrow.

I see, something was missed:

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fd9042b..4640ad3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -135,6 +135,7 @@ static int tcf_del_walker(struct sk_buff *skb,
struct tc_action *a)
        for (i = 0; i < (hinfo->hmask + 1); i++) {
                head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
                hlist_for_each_entry_safe(p, n, head, tcfc_head) {
+                       a->priv = p;
                        ret = tcf_hash_release(a, 0);
                        if (ret == ACT_P_DELETED) {
                                module_put(a->ops->owner);

I will update and resend the last 4 patches in this series.
