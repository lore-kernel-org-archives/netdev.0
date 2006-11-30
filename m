From: Wenji Wu <wenji@fnal.gov>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Wed, 29 Nov 2006 19:56:58 -0600
Message-ID: <2f14bf623344.456de60a@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:64502 "EHLO mailgw1.fnal.gov")
	by vger.kernel.org with ESMTP id S1755139AbWK3B47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 20:56:59 -0500
To: David Miller <davem@davemloft.net>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, when CONFIG_PREEMPT is disabled, the "problem" won't happen. That is why I put "for 2.6 desktop, low-latency desktop" in the uploaded paper. This "problem" happens in the 2.6 Desktop and Low-latency Desktop.

>We could also pepper tcp_recvmsg() with some very carefully placed preemption disable/enable calls to deal with this even with CONFIG_PREEMPT enabled.

I also think about this approach. But since the "problem" happens in the 2.6 Desktop and Low-latency Desktop (not server), system responsiveness is a key feature, simply placing preemption disabled/enable call might not work.  If you want to place preemption disable/enable calls within tcp_recvmsg, you have to put them in the very beginning and end of the call. Disabling preemption would degrade system responsiveness.

wenji



----- Original Message -----
From: David Miller <davem@davemloft.net>
Date: Wednesday, November 29, 2006 7:13 pm
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP

> From: Andrew Morton <akpm@osdl.org>
> Date: Wed, 29 Nov 2006 17:08:35 -0800
> 
> > On Wed, 29 Nov 2006 16:53:11 -0800 (PST)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > 
> > > Please, it is very difficult to review your work the way you have
> > > submitted this patch as a set of 4 patches.  These patches have 
> not> > been split up "logically", but rather they have been split 
> up "per
> > > file" with the same exact changelog message in each patch posting.
> > > This is very clumsy, and impossible to review, and wastes a lot of
> > > mailing list bandwith.
> > > 
> > > We have an excellent file, called 
> Documentation/SubmittingPatches, in
> > > the kernel source tree, which explains exactly how to do this
> > > correctly.
> > > 
> > > By splitting your patch into 4 patches, one for each file touched,
> > > it is impossible to review your patch as a logical whole.
> > > 
> > > Please also provide your patch inline so people can just hit reply
> > > in their mail reader client to quote your patch and comment on it.
> > > This is impossible with the attachments you've used.
> > > 
> > 
> > Here you go - joined up, cleaned up, ported to mainline and test-
> compiled.> 
> > That yield() will need to be removed - yield()'s behaviour is 
> truly awful
> > if the system is otherwise busy.  What is it there for?
> 
> What about simply turning off CONFIG_PREEMPT to fix this "problem"?
> 
> We always properly run the backlog (by doing a release_sock()) before
> going to sleep otherwise except for the specific case of taking a page
> fault during the copy to userspace.  It is only CONFIG_PREEMPT that
> can cause this situation to occur in other circumstances as far as I
> can see.
> 
> We could also pepper tcp_recvmsg() with some very carefully placed
> preemption disable/enable calls to deal with this even with
> CONFIG_PREEMPT enabled.
> 

