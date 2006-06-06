From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 2/2] e1000: remove risky prefetch on next_skb->data
Date: Mon, 5 Jun 2006 17:26:41 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0606051719440.1168@jbrandeb-desk.amr.corp.intel.com>
References: <20060605230917.12584.55755.stgit@gitlost.site>
 <20060605231127.12584.14321.stgit@gitlost.site> <4484BC62.3090707@hp.com>
 <Pine.WNT.4.63.0606051707520.1168@jbrandeb-desk.amr.corp.intel.com>
 <4484C95B.6010009@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:14563 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751183AbWFFA1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 20:27:06 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4484C95B.6010009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Jun 2006, Rick Jones wrote:
> Brandeburg, Jesse wrote:
> > Hi Rick, according to our reporter, receives break.  The prefetch (not
> > always, but sometimes) lets the processor get junk from the prefetched
> > area.  Apparently this version of arm doesn't quite do as strict
> > enforcement of bus snoops as x86, ia64, (and even pSeries!) does.
> 
> Bear with me, I'm a software guy :)  I interpret that to mean that the
> processor is basically broken?  If so, wouldn't it be the case that
> prefetch() needs to become a noop on that processor?

For a software guy, you're making a large leap :-) I wouldn't say the 
processor is broken, it is more sensitive to our (admittedly) bad behavior 
when prefetching data for one descriptor *past* any that we currently 
*know* are done.  ARM/XSCALE is able to use prefetch all over the place in 
its arch specific code with no problems (i'm relying on advice from 
someone else on this, i haven't validated with mine own eyes)

Someone else had complained about this particular prefetch anyway (and it 
was the most speculative with the least amount of gain) on the list 
before, so given this information we're trying to take the conservative 
route.

This patch was tested by the reporter and he was pleased with the result.

> > This manifested with a large drop in receive peformance using TCP,
> > probably because it was retransmitting frequently.
> 
> I forget - what were the gains on the other CPUs?

One system (from a while back) I have numbers for showed a 10% increase in 
packets per second that could be handled using netperf udp receive, with 
the prefetch code in place.

And to Andi's make that came in while I was typing this, I reiterate I do 
not believe ARM/XSCALE prefetch to be broken.

Jesse
