From: Florian Westphal <fw@strlen.de>
Subject: Re: Fwd: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Wed, 30 Jul 2014 08:37:03 +0200
Message-ID: <20140730063703.GA24753@breakpoint.cc>
References: <1836813.giEndUKvmp@storm>
 <20140730002255.GA16109@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47793 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754208AbaG3GhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 02:37:08 -0400
Content-Disposition: inline
In-Reply-To: <20140730002255.GA16109@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> wrote:

[ CCing David.  If I understood him correctly, he recommended to revert
  the GRO forwarding changes for oldstable 3.2/3.4.y series. I second
  this.  But see below for answer to your question ]

> On Fri, Jul 11, 2014 at 05:12:55PM +0200, Thomas Jarosch wrote:
> > Subject: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
> > Date: Friday, 27. June 2014, 11:05:25
> > From: Florian Westphal <fw@strlen.de>
> > To: jungwon park <jwpark2@whitecode.co.kr>
> > CC: netdev@vger.kernel.org
> > 
> > jungwon park <jwpark2@whitecode.co.kr> wrote:
> > > When using the linux router is turned on GRO, router send the 
> > 'fragmentation
> > > needed' packets to the sender.
> > 
> > Indeed 8-(
> > 
> > > When I turned off GRO, the router operate normally, and there is no 
> > problem.
> > > and with 3.4.91 kernel, the router has no problem.
> > > 
> > > I doubt 'ipv4: ip_forward: fix inverted local_df test' patch.
> > > (http://patchwork.ozlabs.org/patch/345509/)
> > > When I revert this patch, the router has no problem.
> > 
> > Can you please cherry-pick following patch on top of vanilla 3.4.92?
> > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
> > 
> > commit 21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
> > Author: Eric Dumazet <edumazet@google.com>
> > ipv4: set transport header earlier
> > 
> > I think that should fix this bug, it should apply cleanly on top of
> > 3.4.y tree.
> > 
> > [ patch is in 3.11, also backported to 3.10.y tree ]
> > 
> > The problem is that, when dealing with GRO packets, we try to determine
> > the size of the individual packets.  To do this, we rely on the
> > transport header.
> > 
> > Unfortunately the transport header is not set for the forward path in 3.4,
> > so we look at the network header instead.
> 
> Why would this patch matter, as commit 45f00f99d6e, which this patch
> fixes, is not in the 3.4-stable tree at all.

It helps, because I underestimated the changes the network stacki went through
since 3.2 and 3.4 had been released.

The GRO forwarding change, (fe6cc55f3a9a053482a76f5a6b2257cee51b4663
upstream) depends on having the transport header available in the
forward path, and not just in the input/local delivery path.

The Patch from Eric Dumazet that I referenced above made this change.
So, while its unrelated to the GRO forward patch, it is a dependency.

However, given the numerous problems reported with the GRO changes in
older stable kernels I think the commit
29a3cd46644ec8098dbe1c12f89643b5c11831a9 in 3.4.y should be reverted.

[ In 3.2.y its caa5344994778a2b4725b2d75c74430f76925e4a ]

> Also, network stable patches need to go through the network maintainer,
> not me directly.

Greg, is above explanation enough for you to revert?
If not, what can I do to help?

David, in case I remember wrong and you did not recommend the revert
after all, do you want me to submit 3.2/3.4.y backport of Erics
'set transport header earlier' patch?

Thanks,
Florian
