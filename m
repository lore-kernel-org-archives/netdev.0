From: Tom Herbert <tom@herbertland.com>
Subject: Re: Initial thoughts on TXDP
Date: Fri, 2 Dec 2016 09:12:39 -0800
Message-ID: <CALx6S367+xaF_aA4wUk6E5n-Tao0hebkef9LFJOEp4PdwLv1vw@mail.gmail.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201024407.GE26507@breakpoint.cc> <CALx6S36ywu3ruY7AFKYk=N4Ekr5zjY33ivx92EgNNT36XoXhFA@mail.gmail.com>
 <859a0c99-f427-1db8-d260-1297777792fb@stressinduktion.org>
 <CALx6S350eCYS63dGiR+X+nVvqF_uGJop9Z_m7SmZf9QXr-rrfg@mail.gmail.com> <cb2e6263-d981-eccf-cea7-39392ceb67b5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jesper Dangaard Brouer <jbrouer@redhat.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:34401 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753799AbcLBRMx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:12:53 -0500
Received: by mail-qt0-f170.google.com with SMTP id n6so258138364qtd.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 09:12:41 -0800 (PST)
In-Reply-To: <cb2e6263-d981-eccf-cea7-39392ceb67b5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016 at 6:36 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 01/12/16 23:46, Tom Herbert wrote:
>> The only time we
>> _really_ to allocate an skbuf is when we need to put the packet onto a
>> queue. All the other use cases are really just to pass a structure
>> containing a packet from function to function. For that purpose we
>> should be able to just pass a much smaller structure in a stack
>> argument and only allocate an skbuff when we need to enqueue. In cases
>> where we don't ever queue a packet we might never need to allocate any
>> skbuff
> Now this intrigues me, because one of the objections to bundling (vs GRO)
> was the memory usage of all those SKBs.  IIRC we already do a 'GRO-like'
> coalescing when packets reach a TCP socket anyway (or at least in some
> cases, not sure if all the different ways we can enqueue a TCP packet for
> RX do it), but if we could carry the packets from NIC to socket without
> SKBs, doing so in lists rather than one-at-a-time wouldn't cost any extra
> memory (the packet-pages are all already allocated on the NIC RX ring).
> Possibly combine the two, so that rather than having potentially four
> versions of each function (skb, skbundle, void*, void* bundle) you just
> have the two 'ends'.
>
Yep, seems like a good idea to incorporate bundling into TXDP from the get-go.

Tom

> -Ed
