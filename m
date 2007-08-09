From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 09 Aug 2007 19:57:55 +0200
Message-ID: <1186682275.9669.12.camel@localhost>
References: <20070808230733.GA17270@shell.boston.redhat.com>
	 <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
	 <46BAC2BE.1090106@redhat.com>  <46BB508B.7050601@redhat.com>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:52953 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbXHIRyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 13:54:18 -0400
In-Reply-To: <46BB508B.7050601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-09 at 13:36 -0400, Chuck Ebbert wrote:
> > Fair enough.  Casting to (volatile int *) will give us the behavior
> > people expect when using atomic_t without needing to use inefficient
> > barriers.
> > 
> 
> You can use this forget() macro to make the compiler reread a
> variable:
> 
> #define forget(var) asm volatile ("" : "=m"(var))

You need to specify a "m"(var) input constraint as well. Without it the
compiler might remove the initialization of var. E.g.

void fn(void)
{
	int var = 0;
	forget(var);
	/* now var can have any value. */
}

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


