From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/1] net sched: Added the TC_LINKLAYER_CUSTOM linklayer
 type
Date: Tue, 4 Jul 2017 07:48:32 +0200
Message-ID: <20170704054832.GA1865@nanopsycho>
References: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, McCabe@rockwellcollins.com
To: "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34292 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdGDFsg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 01:48:36 -0400
Received: by mail-wr0-f193.google.com with SMTP id k67so46110994wrc.1
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 22:48:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 04, 2017 at 02:14:25AM CEST, Robert.McCabe@rockwellcollins.com wrote:
>This is to support user-space modification of the qdisc stab.
>
>Signed-off-by: McCabe, Robert J <Robert.McCabe@rockwellcollins.com>
>---
> include/uapi/linux/pkt_sched.h | 1 +
> net/sched/sch_api.c            | 2 ++
> 2 files changed, 3 insertions(+)
>
>diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
>index 099bf55..289bb81 100644
>--- a/include/uapi/linux/pkt_sched.h
>+++ b/include/uapi/linux/pkt_sched.h
>@@ -82,6 +82,7 @@ enum tc_link_layer {
> 	TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
> 	TC_LINKLAYER_ETHERNET,
> 	TC_LINKLAYER_ATM,
>+	TC_LINKLAYER_CUSTOM,
> };
> #define TC_LINKLAYER_MASK 0x0F /* limit use to lower 4 bits */
> 
>diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>index 43b94c7..174a925 100644
>--- a/net/sched/sch_api.c
>+++ b/net/sched/sch_api.c
>@@ -533,6 +533,8 @@ static int qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *stab)
> 		goto nla_put_failure;
> 	if (nla_put(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts))
> 		goto nla_put_failure;
>+	if (nla_put(skb, TCA_STAB_DATA, sizeof(stab->szopts)*sizeof(u16), &stab->data))
>+		goto nla_put_failure;
 
You dump stab->data to user. How is this related to TC_LINKLAYER_CUSTOM
and howcome this "is to support user-space modification of the qdisc
stab" as your description says? I'm confused...



> 	nla_nest_end(skb, nest);
> 
> 	return skb->len;
>-- 
>2.7.4
>
