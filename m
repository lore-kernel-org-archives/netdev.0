From: Anton Blanchard <anton@samba.org>
Subject: Re: some TSO analysis
Date: Thu, 11 Nov 2004 19:36:47 +1100
Message-ID: <20041111083647.GA20769@krispykreme.ozlabs.ibm.com>
References: <20041111050608.GG1922@krispykreme.ozlabs.ibm.com> <E1CS9Fm-0004hC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CS9Fm-0004hC-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> >  data: 1634 frags: 1408 4096 4096 4096 2108 4
> > 
> >  Is there a reason why the remaining 1408 bytes cant be stuffed into
> >  skb->data? Or is that an issue with MTU sized buffers?
> 
> The reason is that the skb has to accomodate other things like
> headers and skb_shared_info.  It seems to have added up to a
> quite considerable value in your case.
> 
> Perhaps sendmsg should check whether the data can fit in the space
> available in skb->data, and if not just go for a fragment right away.

Originally I thought we could save ourselves a fragment. However
thinking about it more we will always have at least the headers in 
skb->data. If so there isnt much to gain by spilling into the fragment
straight away. Or am I wrong?

> This is understandable.  You really need to have a rcv window that's
> much bigger than 64K to have any chance of filling up the TSO packet
> with tcp_tso_win_divisor set to 8.

That makes sense.

> BTW, how did you measure the gains?

The TSO gains? On older 2.6 the TSO gain was easy to see on a web
benchmark. On recent kernels it isnt, but we havent tested a divisor
of 4 or 2 yet.

Im interested if the divisor of 8 was based on some testing, or if we
can tune the default a bit. It would be nice for TSO to kick in on
normal workloads (like web serving).

Anton
