From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: fix proxy ARP entries listing on a netns
Date: Wed, 23 Nov 2011 17:36:13 -0500 (EST)
Message-ID: <20111123.173613.1360696422325749253.davem@davemloft.net>
References: <1321904774-3030-1-git-send-email-jorge@dti2.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582Ab1KWWgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 17:36:21 -0500
In-Reply-To: <1321904774-3030-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Date: Mon, 21 Nov 2011 20:46:14 +0100

> @@ -2397,6 +2397,7 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
>  	struct net *net = seq_file_net(seq);
>  	struct neigh_table *tbl = state->tbl;
>  
> +restart:
>  	pn = pn->next;
>  	while (!pn) {

We don't need to use goto to fix this bug, instead change this assignment
to something like:

	do {
		pn = pn->next;
	} while (pn && !net_eq(pneigh_net(pn), net));

and this way it will mirror the while loop inside of the "while (!pn)"
code block.
