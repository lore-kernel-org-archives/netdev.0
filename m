From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v2 5/8] net: tc: helper functions to query
 action types
Date: Tue, 16 Feb 2016 21:26:58 +0100
Message-ID: <20160216202658.GE2246@nanopsycho.orion>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
 <20160216060216.32452.72576.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38182 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535AbcBPU1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:27:00 -0500
Received: by mail-wm0-f45.google.com with SMTP id a4so117664373wme.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:27:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160216060216.32452.72576.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 16, 2016 at 07:02:16AM CET, john.fastabend@gmail.com wrote:
>This is a helper function drivers can use to learn if the
>action type is a drop action.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>---
> include/net/tc_act/tc_gact.h |   16 ++++++++++++++++
> 1 file changed, 16 insertions(+)
>
>diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
>index 592a6bc..3067a10 100644
>--- a/include/net/tc_act/tc_gact.h
>+++ b/include/net/tc_act/tc_gact.h
>@@ -2,6 +2,7 @@
> #define __NET_TC_GACT_H
> 
> #include <net/act_api.h>
>+#include <linux/tc_act/tc_gact.h>
> 
> struct tcf_gact {
> 	struct tcf_common	common;
>@@ -15,4 +16,19 @@ struct tcf_gact {
> #define to_gact(a) \
> 	container_of(a->priv, struct tcf_gact, common)
> 
>+#ifdef CONFIG_NET_CLS_ACT
>+static inline bool is_tcf_gact_dropped(const struct tc_action *a)

Meybe would be better to name this "is_tcf_gact_shot" for consistency?
