From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 1/6] netfilter: sanity checks on NFPROTO_NUMPROTO
Date: Mon, 14 May 2012 17:00:48 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1205141659410.11548@frira.vanv.qr>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:47337 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755667Ab2ENPAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 11:00:50 -0400
In-Reply-To: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2012-05-14 15:56, Alban Crequy wrote:

>With the NFPROTO_* constants introduced by commit 7e9c6e ("netfilter: Introduce
>NFPROTO_* constants"), it is too easy to confuse PF_* and NFPROTO_* constants
>in new protocols.

>index e1b7e05..4f16552 100644
>--- a/net/netfilter/core.c
>+++ b/net/netfilter/core.c
>@@ -67,6 +67,11 @@ int nf_register_hook(struct nf_hook_ops *reg)
> 	struct nf_hook_ops *elem;
> 	int err;
> 
>+	if (reg->pf >= NFPROTO_NUMPROTO || reg->hooknum >= NF_MAX_HOOKS) {
>+		BUG();
>+		return 1;
>+	}

Like always, I'd prefer a WARN() instead, here paired with return -EINVAL.
Especially when the error path is (seems) simple, halting the entire machine
does not look very nice.
