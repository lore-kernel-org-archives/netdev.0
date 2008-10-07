From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 7 Oct 2008 18:29:02 +0400
Message-ID: <20081007142902.GA26302@2ka.mipt.ru>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <48EA9A59.1090306@acm.org> <20081007083750.GB17079@2ka.mipt.ru> <48EB6F2D.100@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:57631 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753638AbYJGOpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 10:45:19 -0400
Content-Disposition: inline
In-Reply-To: <48EB6F2D.100@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 09:16:13AM -0500, Christoph Lameter (cl@linux-foundation.org) wrote:
> > I tested skb destruction via RCU path, and got 2.5 times worse numbers
> > with small-packets-bulk-transfer workload.
> 
> Was this with regular RCU freeing? This will cool down the cacheline before
> frees. You need SLAB_DESTROY_BY_RCU to keep the objects cache hot.

I believe there were no SLAB_DESTROY_BY_RCU 2 yars ago :)

It was pure call_rcu(&skb->rcu, real_skb_freeing), where
real_skb_freeing() just did usual kfree().

-- 
	Evgeniy Polyakov
