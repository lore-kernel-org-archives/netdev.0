From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bpf: make programs see skb->data == L2
 for ingress and egress
Date: Thu, 04 Jun 2015 01:11:53 -0700 (PDT)
Message-ID: <20150604.011153.2117612661989458005.davem@davemloft.net>
References: <1433394431-30838-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, jhs@mojatatu.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbbFDILy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:11:54 -0400
In-Reply-To: <1433394431-30838-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed,  3 Jun 2015 22:07:10 -0700

> +	u32 at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;

Please use a 'bool' for this.

> @@ -64,6 +64,7 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  {
>  	struct cls_bpf_head *head = rcu_dereference_bh(tp->root);
>  	struct cls_bpf_prog *prog;
> +	u32 at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
>  	int ret = -1;
>  
>  	if (unlikely(!skb_mac_header_was_set(skb)))

Likewise.

Thank you.
