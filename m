From: Thiago Macieira <thiago.macieira@intel.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Mon, 14 Aug 2017 10:02:23 -0700
Message-ID: <13347366.nbnduK6AMs@tjmaciei-mobl1>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <2828157.5Eig1SAfYW@tjmaciei-mobl1> <CAF=yD-+k79=fykYs5x5-7AvE85+JPXv=NcfDy8X-4AGP8P85Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22540 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750994AbdHNRrF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 13:47:05 -0400
In-Reply-To: <CAF=yD-+k79=fykYs5x5-7AvE85+JPXv=NcfDy8X-4AGP8P85Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 14 August 2017 09:33:48 PDT Willem de Bruijn wrote:
> > But here's a question: if the peek offset is equal to the length, should
> > the reading return an empty datagram? This would indicate to the caller
> > that there was a datagram there, which was skipped over.
> 
> In the general case, no, it should read at the offset, which is the next
> skb.

I beg to differ. In this particular case, we are talking about datagrams. If 
it were stream sockets, I would agree with you: just skip to the next. But in 
datagrams, the same way you do return zero-sized ones, I would return an empty 
one if you peeked at or past the end.

> Since we only need to change no-offset semantics to fix this bug,
> I would not change this behavior, which is also expected by some
> applications by now.

Do applications using SOCK_DGRAM rely on the behaviour of skipping over 
datagrams that are too short?

> > That's how we deal with empty datagrams anyway.
> 
> What is? With no-offset and a zero payload skb at the head, peek
> or recv returns 0, right?

Right.

-- 
Thiago Macieira - thiago.macieira (AT) intel.com
  Software Architect - Intel Open Source Technology Center
