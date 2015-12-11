From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v4 4/4] ila: Add generic ILA translation facility
Date: Fri, 11 Dec 2015 12:19:04 +0100
Message-ID: <20151211111904.GB5665@breakpoint.cc>
References: <1449793173-4086221-1-git-send-email-tom@herbertland.com>
 <1449793173-4086221-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50454 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753232AbbLKLTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 06:19:10 -0500
Content-Disposition: inline
In-Reply-To: <1449793173-4086221-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> +static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {
> +	{
> +		.hook = ila_nf_input,
> +		.pf = NFPROTO_IPV6,
> +		.hooknum = NF_INET_PRE_ROUTING,
> +		.priority = -1,
[..]

> +int ila_xlat_init(void)
[..]

> +	for (; nf_hook < ARRAY_SIZE(ila_nf_hook_ops); nf_hook++) {
> +		ret = nf_register_hook(&ila_nf_hook_ops[nf_hook]);

Nit:

We have nf_register_hooks() which does "all or none" registration
for you.

How likely is it that ILA is done in initial ns only on setups with
lots of net namespaces?

The problem with "nf_register_hook(s)" is that the hooks are placed
in all namespaces & inherited by all newly created namespaces.

So if we do ILA in init ns it & pass such skbs to other netns
it would be preferable to use nf_register_net_hooks in a namespace
once the first ila translation is added within that namespace.
