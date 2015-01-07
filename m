From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 6/7] rhashtable: initialize atomic nelems
 variable
Date: Wed, 7 Jan 2015 10:36:49 +0000
Message-ID: <20150107103649.GN21820@casper.infradead.org>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
 <1420609318-3261-7-git-send-email-ying.xue@windriver.com>
 <20150107095332.GK21820@casper.infradead.org>
 <54AD09CD.3010100@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33101 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbbAGKgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 05:36:52 -0500
Content-Disposition: inline
In-Reply-To: <54AD09CD.3010100@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 06:26pm, Ying Xue wrote:
> I am not sure whether we really need to reinitialize atomic variable
> again although we have reset it with memset() or something else. But I
> see many places in kernel where we do this, for example:
> 
> Although we use kmem_cache_zalloc() to allocate "net" structure instance
> in net_alloc(), there are still several places where to reinitialize its
> atomic variables again:
> 
> setup_net()
>   atomic_set(&net->use_count, 0);
> 
> rt_genid_init()
>   atomic_set(&net->ipv4.rt_genid, 0);
>   atomic_set(&net->fnhe_genid, 0);
> 
> Can you please definitely confirm that the reinitialisation is redundant
> for us?

I see examples for both, explicit initialization and dependence on
a previous memset. I'm not sure what is the preferred way.

I'll provide my ACK since this obviously doesn't break anything and
leave it up to Dave.

Acked-by: Thomas Graf <tgraf@suug.ch>
