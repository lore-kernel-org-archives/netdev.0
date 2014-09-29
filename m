From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: tc rsvp filter show broke
Date: Sun, 28 Sep 2014 18:40:11 -0700
Message-ID: <CAM_iQpVF8bHN8WNNH5kHyanj+fLE6kbsFOwQA+t_z_=UK_v=+w@mail.gmail.com>
References: <5425A545.1040907@gmail.com>
	<5425ED2D.1000005@mojatatu.com>
	<5425F5CC.4070507@intel.com>
	<542823CE.9020301@mojatatu.com>
	<CAM_iQpXzXHc7o1WOtkNnF+io_WZFP+DP4zWm8PZbwX7SC38=Pw@mail.gmail.com>
	<54284A51.5080805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:61621 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbaI2BkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 21:40:12 -0400
Received: by mail-vc0-f176.google.com with SMTP id hq11so2054319vcb.21
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 18:40:11 -0700 (PDT)
In-Reply-To: <54284A51.5080805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 10:50 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
>
> I don't think we need this change, (or perhaps it needs to be a bit
> more complete if something is missing) take a look a
> tcf_exts_validate(), notice the policer is added to act->list so the
> if block in dump() work out,

I thought it's clear that act->list is correct here. :)

I was thinking the dump logic was wrong, but you are right that
it should match the logic in validate. Actually the bug is we forgot
to copy exts->type, I am going to submit a patch below:

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 77147c8..aad6a67 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -549,6 +549,7 @@ void tcf_exts_change(struct tcf_proto *tp, struct
tcf_exts *dst,
  tcf_tree_lock(tp);
  list_splice_init(&dst->actions, &tmp);
  list_splice(&src->actions, &dst->actions);
+ dst->type = src->type;
  tcf_tree_unlock(tp);
  tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
 #endif
