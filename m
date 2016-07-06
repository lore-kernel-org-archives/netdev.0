From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 06/26] netfilter: conntrack: align nf_conn on cacheline
 boundary
Date: Wed, 6 Jul 2016 14:45:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4F18C1@AcuExch.aculab.com>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
 <1467815048-2240-7-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:57251 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650AbcGFOra convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 10:47:30 -0400
In-Reply-To: <1467815048-2240-7-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 06 July 2016 15:24
> From: Florian Westphal <fw@strlen.de>
> 
> increases struct size by 32 bytes (288 -> 320), but it is the right thing,
> else any attempt to (re-)arrange nf_conn members by cacheline won't work.
...
>  	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
>  						sizeof(struct nf_conn), 0,
> -						SLAB_DESTROY_BY_RCU, NULL);
> +						SLAB_DESTROY_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);

What happens on systems with cache lines that are longer than 64 bytes?
(I'm pretty sure some ppc systems have long cache lines.)

	David
