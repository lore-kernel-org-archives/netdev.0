From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v2 1/1] net: sched: Introduce connmark action
Date: Sun, 18 Jan 2015 13:00:11 -0800
Message-ID: <CAHA+R7Muz_d47NX01tKO7v7V7m=5mKf+BPP1jo9dEH==8R6bgw@mail.gmail.com>
References: <1421611245-18492-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, nbd@openwrt.org,
	pablo@netfilter.org, Florian Westphal <fw@strlen.de>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33309 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbARVAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 16:00:13 -0500
Received: by mail-wg0-f51.google.com with SMTP id l18so6572333wgh.10
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 13:00:12 -0800 (PST)
In-Reply-To: <1421611245-18492-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2015 at 12:00 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> +
> +MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
> +MODULE_DESCRIPTION("Connection tracking mark restoring");
> +MODULE_LICENSE("GPL");


Please move these to the bottom.

> +
> +static int __init connmark_init_module(void)
> +{
> +       int ret;
> +
> +       ret = tcf_hashinfo_init(&connmark_hash_info, CONNMARK_TAB_MASK);
> +       if (ret)
> +               return ret;
> +

Is this against latest net-next? We don't need to init the hashinfo anymore,
tcf_register_action() already does that.

> +       return tcf_register_action(&act_connmark_ops, CONNMARK_TAB_MASK);
> +}
> +
> +static void __exit connmark_cleanup_module(void)
> +{
> +       tcf_unregister_action(&act_connmark_ops);
> +}
> +

Even if we really needed, you forgot to call tcf_hashinfo_destroy()?

Thanks.
