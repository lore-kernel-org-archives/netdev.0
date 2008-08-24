From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Sun, 24 Aug 2008 14:43:13 +0400
Message-ID: <20080824104313.GA3010@x200.localdomain>
References: <20080821220432.GT31136@x200.localdomain> <alpine.LNX.1.10.0808211903000.20596@fbirervta.pbzchgretzou.qr> <20080822113028.GB2321@x200.localdomain> <alpine.LNX.1.10.0808232034380.8996@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808232034380.8996@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 23, 2008 at 08:35:07PM -0400, Jan Engelhardt wrote:
> 
> On Friday 2008-08-22 07:30, adobriyan@gmail.com wrote:
> >
> >We wait for untracked ct refcount to drop to 1 back:
> >
> >	/* wait until all references to nf_conntrack_untracked are dropped */
> >	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
> >		schedule();
> >
> >Consequently it should be one per netns, otherwise netns A can prevent
> >netns B from stopping.
> >
> 
> But nf_conntrack_cleanup is not per netns, is it?

That's because nf_conntrack_cleanup() is _code_.

If netns A actively uses NOTRACK, untracked ct refcount will be bumped.
And netns B which haven't used NOTRACK at all will wait for netns A to
stop using NOTRACK potentially indefinitely.

> At least I do not think it should be.

