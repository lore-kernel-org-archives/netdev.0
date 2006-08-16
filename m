From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH?] tcp and delayed acks
Date: Wed, 16 Aug 2006 17:41:34 -0400
Message-ID: <20060816214134.GG9519@kvack.org>
References: <20060816205532.GF9519@kvack.org> <20060816121112.0c181ac3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:32401 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S932235AbWHPVlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:41:45 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060816121112.0c181ac3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 12:11:12PM -0700, Stephen Hemminger wrote:
> > is throttled waiting for ACKs to arrive.  The problem is exacerbated when 
> > the sender is using a small send buffer -- running netperf -C -c -- -s 1024 
> > show a miserable 420Kbit/s at essentially 0% CPU usage.  Tests over gige 
> > are similarly constrained to a mere 96Mbit/s.
> 
> What ethernet hardware? The defaults are often not big enough
> for full speed on gigabit hardware. I need increase rmem/wmem to allow
> for more buffering. 

This is for small buffer transmit buffer sizes over either loopback or 
e1000.  The artifact also shows up over localhost for somewhat larger buffer 
sizes, although it is much more difficult to get results that don't have 
large fluctuations because of other scheduling issues.  Pinning the tasks to 
CPUs is on my list of things to try, but something in the multiple variants 
of sched_setaffinity() has resulted in it being broken in netperf.

> The point of delayed ack's was to merge the response and the ack on request/response
> protocols like NFS or telnet. It does make sense to get it out sooner though.

I would like to see what sort of effect this change has on higher latency.  
Ideally, quick ack mode should be doing the right thing, but it might need 
more input about the receiver's intent.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
