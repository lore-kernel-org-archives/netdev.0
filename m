From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: IPv6 and encapsulation headers
Date: Mon, 12 Jul 2004 17:32:52 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407121732.52542.kazunori@miyazawa.org>
References: <20040710033209.GA14316@gondor.apana.org.au> <20040710.133641.132032007.yoshfuji@linux-ipv6.org> <20040710091630.GA16312@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040710091630.GA16312@gondor.apana.org.au>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Herbert,

> On Sat, Jul 10, 2004 at 01:36:41PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ 
wrote:
> > Looks good.
>
> Thanks for reviewing it.
>
> I've got a couple of questions that you might be able to help me with.
>
> It appears that the value of hdr_len in ah6 for transport mode is broken.
> It's setting hdr_len to be skb->h.raw - skb->nh.raw.  When AH is being
> applied outside an ESP tunnel, skb->h.raw will be pointing somewhere
> inside the tunnel.  The end result is that leading bytes of the payload
> inside the tunnel gets moved before the AH header.
>

right, esp6 tunnel doesn't care about skb->h.raw. we need to fix it.

> So should it be changed to ip6_find_1stfragopt() as is the case with
> esp6 and ipcomp6?

Do we need to skip esp or ipcomp payload?
I thinks those are similar with transport layer protocol in outer esp process.
Did I misunderstand your question?

> A second problem is that ip6_find_1stfragopt() seems to be the wrong
> thing to do for ah6/esp6/ipcomp6.  RFC 2402/2406/3173 all say that
> fragment headers should be placed before the encapsulation header.
> So should it be changed accordingly?
>


Because fragmentation takes place after IPsec processing,
do we need to make ip6_find_1stfragopt care fragment header?
I think there is no fragment header in skb at that point.

--Kazunori Miyazawa
