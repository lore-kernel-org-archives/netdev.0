From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 4/7] netfilter: add glue code to integrate nfnetlink_queue
 and ctnetlink
Date: Mon, 4 Jun 2012 15:38:04 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1206041522130.16684@frira.zrqbmnf.qr>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org> <1338812485-4232-5-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1338812485-4232-5-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2012-06-04 14:21, pablo@netfilter.org wrote:
>+static int
>+ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
>+{
>+	const struct nlattr * const cda[CTA_MAX+1];

I suppose you wrote that because the same appears in function
headers/signatures

	void foo(const struct nlattr *const tb[]) { ... }

But there, it is actually equal to

	void foo(const struct nlattr *const *tb) { ... }

In either case, tb is writable. IMHO, [] should be avoided in
signatures to avoid self-confusion, as it seemed to occur in your
case, where cda is - unlike tb - really marked const.
You likely wanted

	const struct nlattr *cda[CTA_MAX+1];

>+       nla_parse_nested((struct nlattr **)cda, CTA_MAX, attr, ct_nla_policy);


