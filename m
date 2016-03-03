From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V1 03/10] net/sched: Macro instead of
 CONFIG_NET_CLS_ACT ifdef
Date: Thu, 3 Mar 2016 10:38:07 +0100
Message-ID: <20160303093807.GA2105@nanopsycho.orion>
References: <1456997006-18538-1-git-send-email-amir@vadai.me>
 <1456997006-18538-4-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35765 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbcCCJiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:38:10 -0500
Received: by mail-wm0-f66.google.com with SMTP id 1so3098086wmg.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 01:38:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456997006-18538-4-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 03, 2016 at 10:23:19AM CET, amir@vadai.me wrote:
>Introduce the macros tc_no_actions and tc_for_each_action to make code
>clearer.
>

<snip>

>@@ -171,5 +171,16 @@ int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
> int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
> int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
> int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
>+
>+#define tc_no_actions(_exts) \
>+	(list_empty(&(_exts)->actions))
>+
>+#define tc_for_each_action(_a, _exts) \
>+	list_for_each_entry(a, &(_exts)->actions, list)
>+#else /* CONFIG_NET_CLS_ACT */
>+
>+#define tc_no_actions(_exts) false

This should be "true".
