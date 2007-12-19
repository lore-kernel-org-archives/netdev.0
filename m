From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Inline local_bh_disable when TRACE_IRQFLAGS
Date: Wed, 19 Dec 2007 15:03:13 +0100
Message-ID: <20071219140313.GE21282@elte.hu>
References: <20071219034033.GA5770@gondor.apana.org.au> <20071219113152.GD20736@elte.hu> <20071219115019.GA9099@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38696 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbXLSOD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 09:03:27 -0500
Content-Disposition: inline
In-Reply-To: <20071219115019.GA9099@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Dec 19, 2007 at 12:31:52PM +0100, Ingo Molnar wrote:
> >
> > > So I'm wondering if it would be reasonable to make it out-of-line 
> > > when TRACE_IRQFLAGS is off.  This may make a difference because 
> > > the networking stack is a frequent user of local_bh_disable and 
> > > local_bh_enable.
> > 
> > do you mean to make it inline again?
> 
> Yes I meant in-line :)

if that decreases code size then i guess we could do that.

> > (btw., generally i think local_bh_disable() is a poor API because it 
> > is opaque about the data structure dependency that it governs. 
> > Explicit exclusion rules generally work better.)
> 
> I see where you're coming from especially with your preemptible 
> softirq work.  However I'm mostly thinking about the existing callers 
> of local_bh_disable in the networking stack.

yeah, i was just commenting on the general concept of 'naked' 
local_bh_disable(). And just to make it clear: with that i'm not 
implying anything about the quality of the networking code - networking 
is one of the cleanest [if not the cleanest] subsystems in the kernel. 

It's just that it's long term more useful for us if our "global scope" 
APIs have direct, programmatic relationship to the data structures / 
data flow they control. So i'd love to have the same flow/performance, 
just coded a bit more explicitly. [preempt_disable() for example has 
similar issues.]

	Ingo
