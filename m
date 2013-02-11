From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 07/11] tbf: ignore max_size check for gso skbs
Date: Mon, 11 Feb 2013 22:02:20 +0100
Message-ID: <20130211210220.GA1560@minipsycho.orion>
References: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
 <1360493539-14868-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:53289 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759563Ab3BKVC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 16:02:26 -0500
Received: by mail-ea0-f182.google.com with SMTP id a12so3051698eaa.41
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 13:02:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360493539-14868-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm. I think that this approach might not be correct after all. This
might break existing setups when user is taking gso into account and
adjust mtu and burst accordingly. After more thorough study, I'm under
impression that gso skbs should not be handled in any different way.

Thoughts?


Sun, Feb 10, 2013 at 11:52:15AM CET, jiri@resnulli.us wrote:
>This check made bigger packets incorrectly dropped. Remove this
>limitation for gso skbs.
>
>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>Acked-by: Eric Dumazet <edumazet@google.com>
>---
> net/sched/sch_tbf.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>index e05710a..dc562a8 100644
>--- a/net/sched/sch_tbf.c
>+++ b/net/sched/sch_tbf.c
>@@ -121,7 +121,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> 	struct tbf_sched_data *q = qdisc_priv(sch);
> 	int ret;
> 
>-	if (qdisc_pkt_len(skb) > q->max_size)
>+	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
> 		return qdisc_reshape_fail(skb, sch);
> 
> 	ret = qdisc_enqueue(skb, q->qdisc);
>-- 
>1.8.1.2
>
