From: Edward Cree <ecree@solarflare.com>
Subject: Re: Initial thoughts on TXDP
Date: Fri, 2 Dec 2016 14:36:33 +0000
Message-ID: <cb2e6263-d981-eccf-cea7-39392ceb67b5@solarflare.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201024407.GE26507@breakpoint.cc>
 <CALx6S36ywu3ruY7AFKYk=N4Ekr5zjY33ivx92EgNNT36XoXhFA@mail.gmail.com>
 <859a0c99-f427-1db8-d260-1297777792fb@stressinduktion.org>
 <CALx6S350eCYS63dGiR+X+nVvqF_uGJop9Z_m7SmZf9QXr-rrfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jesper Dangaard Brouer <jbrouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:64334 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758184AbcLBOg4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 09:36:56 -0500
In-Reply-To: <CALx6S350eCYS63dGiR+X+nVvqF_uGJop9Z_m7SmZf9QXr-rrfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/16 23:46, Tom Herbert wrote:
> The only time we
> _really_ to allocate an skbuf is when we need to put the packet onto a
> queue. All the other use cases are really just to pass a structure
> containing a packet from function to function. For that purpose we
> should be able to just pass a much smaller structure in a stack
> argument and only allocate an skbuff when we need to enqueue. In cases
> where we don't ever queue a packet we might never need to allocate any
> skbuff
Now this intrigues me, because one of the objections to bundling (vs GRO)
was the memory usage of all those SKBs.  IIRC we already do a 'GRO-like'
coalescing when packets reach a TCP socket anyway (or at least in some
cases, not sure if all the different ways we can enqueue a TCP packet for
RX do it), but if we could carry the packets from NIC to socket without
SKBs, doing so in lists rather than one-at-a-time wouldn't cost any extra
memory (the packet-pages are all already allocated on the NIC RX ring).
Possibly combine the two, so that rather than having potentially four
versions of each function (skb, skbundle, void*, void* bundle) you just
have the two 'ends'.

-Ed
