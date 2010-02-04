From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Thu, 04 Feb 2010 08:18:06 -0500
Message-ID: <1265289486.2861.436.camel@tonnant>
References: <1265108690.2861.118.camel@tonnant>
	 <1265134598.2861.191.camel@tonnant> <4B6870AF.6060109@trash.net>
	 <4B6967BC.600@trash.net> <1265222289.2861.290.camel@tonnant>
	 <20100203190948.GA5182@x200> <1265226227.2861.302.camel@tonnant>
	 <4B6ABCB8.4080904@trash.net>
	 <b6fcc0a1002040427n221da433n755350b4a41bbf9b@mail.gmail.com>
	 <4B6ABDEF.8090005@trash.net>
	 <b6fcc0a1002040435t150aa7axf2dc0b139ed8f258@mail.gmail.com>
	 <4B6AC5DC.60301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B6AC5DC.60301@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-02-04 at 14:04 +0100, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
> > On Thu, Feb 4, 2010 at 2:30 PM, Patrick McHardy <kaber@trash.net> wrote:
> >> Alexey Dobriyan wrote:
> >>> On Thu, Feb 4, 2010 at 2:25 PM, Patrick McHardy <kaber@trash.net> wrote:
> >>>> Jon Masters wrote:
> >>>>> On Wed, 2010-02-03 at 21:09 +0200, Alexey Dobriyan wrote:
> >>>>>> On Wed, Feb 03, 2010 at 01:38:09PM -0500, Jon Masters wrote:
> >>>>>>> *). Per namespace cacheing allocation (the cachep bits). We know it's
> >>>>>>> still possible for weirdness to happen in the SLAB cache here.
> >>>>>> Tiny race, needs reproducer.
> >>>>> Maybe. I think it's worth fixing anyway.
> >>>> Absolutely, I'll also apply Eric's patch with the %p fix for the
> >>>> slab name.
> >>> This would show kernel pointers in userspace ;-)
> >>> So, net->id is required.
> >> I don't see the problem. But yes, it would be nicer to have an ID.
> > 
> > This is done (or rather, not done) to not show attackers
> > where data structures are.
> 
> That's news to me, my /proc is full of kernel space pointers,
> including data.

And anyway, you can guess it in many cases. I don't think there's a huge
problem, but you could of course just stash a global atomic somewhere to
keep track of how many of these you've made if that's easier for now.

> In any case, we need a fix for this suitable for 2.6.33. If
> you don't like using the pointer, please send a patch to add
> an id to the network namespaces.

Right. I think the quick solution is fine for 2.6.33. So that makes the
hashtable non-resize patch, the crash fix, and the cachep bits. I will
try to get involved and help you out with the per-ns hashtable clean
rather than just being a whiner :)

Thanks a bunch! Fedora kernels have already been built with this fix,
since it will allow us to close a fair number of "KVM goes boom" bugs.

Jon.


