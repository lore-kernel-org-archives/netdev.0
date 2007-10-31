From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 06/33] mm: allow PF_MEMALLOC from softirq context
Date: Wed, 31 Oct 2007 21:49:24 +1100
Message-ID: <200710312149.25296.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl> <200710311451.56747.nickpiggin@yahoo.com.au> <1193827359.27652.129.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.mail.mud.yahoo.com ([209.191.85.212]:47220 "HELO
	smtp102.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754372AbXJaMCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 08:02:55 -0400
In-Reply-To: <1193827359.27652.129.camel@twins>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 October 2007 21:42, Peter Zijlstra wrote:
> On Wed, 2007-10-31 at 14:51 +1100, Nick Piggin wrote:
> > On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > > Allow PF_MEMALLOC to be set in softirq context. When running softirqs
> > > from a borrowed context save current->flags, ksoftirqd will have its
> > > own task_struct.
> >
> > What's this for? Why would ksoftirqd pick up PF_MEMALLOC? (I guess
> > that some networking thing must be picking it up in a subsequent patch,
> > but I'm too lazy to look!)... Again, can you have more of a rationale in
> > your patch headers, or ref the patch that uses it... thanks
>
> Right, I knew I was forgetting something in these changelogs.
>
> The network stack does quite a bit of packet processing from softirq
> context. Once you start swapping over network, some of the packets want
> to be processed under PF_MEMALLOC.

Hmm... what about processing from interrupt context?
