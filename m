From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: nf_queue: Don't recompute the hook_list
 head
Date: Sat, 20 Jun 2015 20:53:53 +0200
Message-ID: <20150620185353.GA3567@salvia>
References: <87381ne3rq.fsf@x220.int.ebiederm.org>
 <20150620105839.GB3439@salvia>
 <877fqya2wb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35402 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755122AbbFTSsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 14:48:35 -0400
Content-Disposition: inline
In-Reply-To: <877fqya2wb.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2015 at 09:08:20AM -0500, Eric W. Biederman wrote:
> Pablo Neira Ayuso <pablo@netfilter.org> writes:
> 
> > On Fri, Jun 19, 2015 at 05:23:37PM -0500, Eric W. Biederman wrote:
> >> 
> >> If someone sends packets from one of the netdevice ingress hooks to
> >> the a userspace queue, and then userspace later accepts the packet,
> >> the netfilter code can enter an infinite loop as the list head will
> >> never be found.
> >> 
> >> Pass in the saved list_head to avoid this.
> >
> > There is no userspace queueing for netdevice yet, so this can be route
> > through nf-next. Thanks.
> 
> *scratches head* the netdevice queueing is in the netfilter core.
> 
> netfilter_ingress calls nf_hook_slow.  The queuing happens in
> nf_hook_slow if anything returns the verdict queue it.
> 
> This patch applies to Linus's tree.
> 
> So how in the world does this not need to be ported to 4.1?

There is no nfnetlink_queue support for the netdev family at this
moment, so this can't be triggered unless you use an out of tree
module.

I have a patch here to add a static key to disable userspace queueing
per family using a static key so that part would be basically
inactive.

But if you really want to see this in 4.1, no problem, please just let
me know and I'll pass it to David, as I said it's basically not
resolving any urgent problem so this is not harming.

Thank you.
