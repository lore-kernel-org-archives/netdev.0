From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Thu, 26 Feb 2015 07:53:55 +0000
Message-ID: <20150226075354.GA30061@acer.localdomain>
References: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61850 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbBZHyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:54:01 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.02, Alexei Starovoitov wrote:
> On Wed, Feb 25, 2015 at 12:10 PM, Patrick McHardy <kaber@trash.net> wrote:
> > On 25.02, Eric Dumazet wrote:
> >> But if any workload had to grow the table to 2^20 slots, we had to
> >> consume GB of memory anyway to hold sockets and everything.
> >>
> >> Trying to shrink is simply not worth it, unless you expect your host
> >> never reboots and you desperately need back these 8 MBytes of memory.
> >
> > That may be true in the TCP case, but for not for nftables. We might
> > have many sets and, especially when used to represent more complicated
> > classification algorithms, their size might change by a lot.
> 
> sounds like grow/shrink decision cannot be generalized within
> rhashtable, but two callbacks are about to be removed and the
> are costly. So would it make sense to disable auto-expand/shrink
> completely and let nft/tcp call expand/shrink when needed?

My understanding was that Eric was arguing against shrinking in general.
But assuming we have it, what's the downside of also performing
shrinking for TCP?

> nft can potentially do smarter batching this way.
> If it sees a lot of entries are about to be inserted, it can call
> expand directly to quickly grow sparsely populated table
> into large one, and then insert all the entries.
> That will mitigate 'slow rcu' issue as well.

I like that idea.
