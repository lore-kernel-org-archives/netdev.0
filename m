From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 3/6] netfilter: limit the length of the helper name
Date: Wed, 25 Mar 2009 18:32:26 +0100
Message-ID: <49CA6AAA.1050305@trash.net>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <20090316221138.326410717@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35482 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756035AbZCYRce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 13:32:34 -0400
In-Reply-To: <20090316221138.326410717@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Eitzenberger wrote:
> This is necessary in order to have an upper bound for Netlink
> message calculation, which is not a problem at all, as there
> are no helpers with a longer name.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
> 
> Index: net-next-2.6/include/net/netfilter/nf_conntrack_helper.h
> ===================================================================
> --- net-next-2.6.orig/include/net/netfilter/nf_conntrack_helper.h
> +++ net-next-2.6/include/net/netfilter/nf_conntrack_helper.h
> @@ -14,6 +14,8 @@
>  
>  struct module;
>  
> +#define NF_CT_HELPER_NAME_LEN	16
> +
>  struct nf_conntrack_helper
>  {
>  	struct hlist_node hnode;	/* Internal use. */
> Index: net-next-2.6/net/netfilter/nf_conntrack_helper.c
> ===================================================================
> --- net-next-2.6.orig/net/netfilter/nf_conntrack_helper.c
> +++ net-next-2.6/net/netfilter/nf_conntrack_helper.c
> @@ -142,6 +142,7 @@ int nf_conntrack_helper_register(struct 
>  
>  	BUG_ON(me->expect_policy == NULL);
>  	BUG_ON(me->expect_class_max >= NF_CT_MAX_EXPECT_CLASSES);
> +	BUG_ON(strlen(me->name) >= NF_CT_HELPER_NAME_LEN - 1);

This appears to be an off-by-one. A strlen of exactly
NF_CT_HELPER_NAME_LEN - 1 would be fine, right?

No need to resend, just let me know whether I should change it.
