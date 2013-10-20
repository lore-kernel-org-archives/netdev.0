From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 03/17] netfilter: add nftables
Date: Sun, 20 Oct 2013 13:46:03 +0200 (CEST)
Message-ID: <alpine.LSU.2.11.1310201338320.13725@nerf07.vanv.qr>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org> <1381768738-17739-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	kaber@trash.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:37707 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab3JTLqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 07:46:06 -0400
In-Reply-To: <1381768738-17739-4-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2013-10-14 18:38, Pablo Neira Ayuso wrote:
>
>+static int __init nf_table_nat_init(void)
>+{
>+	int err;
>+
>+	list_add_tail(&nf_chain_nat_prerouting.chain.list,
>+		      &nf_table_nat_ipv4.chains);
>+	list_add_tail(&nf_chain_nat_postrouting.chain.list,
>+		      &nf_table_nat_ipv4.chains);
>+	list_add_tail(&nf_chain_nat_output.chain.list,
>+		      &nf_table_nat_ipv4.chains);
>+	list_add_tail(&nf_chain_nat_input.chain.list,
>+		      &nf_table_nat_ipv4.chains);
>+
>+	err = nft_register_table(&nf_table_nat_ipv4, NFPROTO_IPV4);
>+	if (err < 0)
>+		goto err1;

Why do we still have this redundant table separation?

This ugly 90s era relict was a result of the module split,
but given that arbitrary base chain creation is now exposed,
it is no longer necessary. (It was not really necessary
before either, but that is how things grew in the past.)
Don't carry over 90s mistakes.
