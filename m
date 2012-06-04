From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 7/7] netfilter: add user-space connection tracking helper
 infrastructure
Date: Mon, 4 Jun 2012 16:04:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1206041600130.26827@frira.zrqbmnf.qr>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org> <1338812485-4232-8-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:46807 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716Ab2FDOE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 10:04:29 -0400
In-Reply-To: <1338812485-4232-8-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2012-06-04 14:21, pablo@netfilter.org wrote:
>+static int
>+nfnl_cthelper_from_nlattr(struct nlattr *attr, struct nf_conn *ct)
>+{
>+	const struct nf_conn_help *help = nfct_help(ct);
>+
>+	if (help->helper->data_len == 0)
>+		return -EINVAL;
>+
>+	memcpy(&help->data, nla_data(attr), help->helper->data_len);

memcpy(help->data, ...)

>+static int
>+nfnl_cthelper_to_nlattr(struct sk_buff *skb, const struct nf_conn *ct)
>+{
>+	const struct nf_conn_help *help = nfct_help(ct);
>+
>+	if (help->helper->data_len &&
>+	    nla_put(skb, CTA_HELP_INFO, help->helper->data_len, &help->data))
>+		goto nla_put_failure;

help->data
