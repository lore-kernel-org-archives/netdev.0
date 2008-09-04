From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Thu, 04 Sep 2008 18:54:16 +0200
Message-ID: <48C012B8.10606@trash.net>
References: <20080821220432.GT31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33589 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbYIDQyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 12:54:19 -0400
In-Reply-To: <20080821220432.GT31136@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adobriyan@gmail.com wrote:
> Make untracked conntrack per-netns. Compare conntracks with relevant
> untracked one.
> 
> The following code you'll start laughing at this code:
> 
> 	if (ct == ct->ct_net->ct.untracked)
> 		...
> 
> let me remind you that ->ct_net is set in only one place, and never
> overwritten later.
> 
> All of this requires some surgery with headers, otherwise horrible circular
> dependencies. And we lost nf_ct_is_untracked() as function, it became macro.

I think you could avoid this mess by using a struct nf_conntrack
for the untracked conntrack instead of struct nf_conn. It shouldn't
make any difference since its ignored anyways.

> 
>  struct netns_ct {
>  	atomic_t		count;
> @@ -12,5 +13,7 @@ struct netns_ct {
>  	struct hlist_head	*expect_hash;
>  	int			expect_vmalloc;
>  	struct hlist_head	unconfirmed;
> +	/* Fake conntrack entry for untracked connections */
> +	struct nf_conn		untracked;
>  };
