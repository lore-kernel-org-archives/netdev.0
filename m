From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: avoid allocating variable size
 array on stack
Date: Wed, 1 May 2013 11:53:16 +0100
Message-ID: <20130501105316.GE9780@zion.uk.xensource.com>
References: <1367340644-19690-1-git-send-email-wei.liu2@citrix.com>
 <1367340644-19690-3-git-send-email-wei.liu2@citrix.com>
 <1367404361.3142.686.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jbeulich@suse.com" <jbeulich@suse.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:5055 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755667Ab3EAKxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 06:53:17 -0400
Content-Disposition: inline
In-Reply-To: <1367404361.3142.686.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 01, 2013 at 11:32:41AM +0100, Ian Campbell wrote:
> On Tue, 2013-04-30 at 17:50 +0100, Wei Liu wrote:
> > Tune xen_netbk_count_requests to not touch working array beyond limit, so that
> > we can make working array size constant.
> 
> Is this really correct when max_skb_slots > XEN_NETIF_NR_SLOTS_MIN?
> Seems like we would either overrun the array or drop frames which
> max_skb_slots suggests we should accept?
> 

So the max_skb_slots for now is the standard to determine whether a
guest is malicious, not the maximum slots we can process.

> If anything the array would need to be size by XEN_NETIF_NR_SLOTS_MAX
> which a) doesn't exist and b) would be worse than using max_skb_slots. I
> wouldn't be particularly averse to enforcing some sensible maximum on
> max_skb_slots.
> 

A sensible one is tricky, but presumably we would need it sooner or
later.

> Other options:
> 
> Handle batches of work in <max_skb_slots sized bundles, but that gets
> complex when you consider the case of an skb which crosses multiple such
> bundles.
> 
> xen_netbk_get_requests() copes the tx req again into the pending_tx_info
> -- any way we can arrange for this to just happen right in the first
> place?
> 

Isn't the point of having xen_netbk_count_requests to drop malformed
packets before wasting any effort processing them?

In the current design pending_tx_info only have valid tx request.

> Or perhaps it is time for each vif to allocate a page of its own to
> shadow the shared ring, and remove that field from pending_tx_info?
> (which isn't really a net increase in memory usage, but might simplify
> some things?)
> 

Not sure about this, will need to look into it.


Wei.
