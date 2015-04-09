From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress
 qdisc
Date: Wed, 08 Apr 2015 22:44:04 -0400 (EDT)
Message-ID: <20150408.224404.1913719826015357860.davem@davemloft.net>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>
	<1428535575-7736-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbbDICoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 22:44:06 -0400
In-Reply-To: <1428535575-7736-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed,  8 Apr 2015 16:26:15 -0700

> index 4cd5cf1aedf8..887033fbdfa6 100644
> --- a/net/sched/act_csum.c
> +++ b/net/sched/act_csum.c
> @@ -565,6 +565,8 @@ static struct tc_action_ops act_csum_ops = {
>  	.act		= tcf_csum,
>  	.dump		= tcf_csum_dump,
>  	.init		= tcf_csum_init,
> +	/* todo: fix pskb_may_pull in tcf_csum to not assume L2 */
> +	.flags		= TCA_NEEDS_L2,
>  };
>  
>  MODULE_DESCRIPTION("Checksum updating actions");


All this module really cares about is where skb_network_header() is
for data accesses.  And a simple offset would allow it to calculate
the pskb_may_pull() length argument correctly.

And it would therefore work without all of these expensive SKB share
check calls etc.

I really don't like your approach, and I'd rather you propagate the
offset into the BPF programs you generate.  I bet you can do it in
an efficient way, and just haven't put in the effort to discover
how.
