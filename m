From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 and encapsulation headers
Date: Tue, 13 Jul 2004 20:48:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040713104837.GA9670@gondor.apana.org.au>
References: <20040710033209.GA14316@gondor.apana.org.au> <200407121732.52542.kazunori@miyazawa.org> <20040712104710.GC965@gondor.apana.org.au> <200407131042.41346.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <200407131042.41346.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 13, 2004 at 10:42:41AM +0900, Kazunori Miyazawa wrote:
>
> I agree with you. It should uses ip6_find_1stfragopt.
> However please consider zero_out_mutable_opts in ah6.c clears second 
> destination options. We need to get the copy length by other way.
> Because ip6_find_1stfragopt returns the insert point of IPsec.

Are there situations where it is desirable to have mutable options
in the second destination header? Isn't the idea of the second
destination header so that it is processed only by the final
destination? I would've thought that it only made sense to have
immutable options there.

In fact if ESP were present then it guarantees the second dest
header to be immutable.  So perhaps we should simply disallow
users from putting mutable options in the second destination
header.  Or we can document it as undefined and let the user
handle the consequences (cf HDRINCL with raw sockets + IPsec).

BTW, the current code in ipv6_clear_mutable_options() that deals
with NEXTHDR_AUTH is buggy.  It assumes that there are at most two
AH headers.

> > Hmm, what about address spoofing? Is there code in IPv6 to prevent
> > another machine from relaying a packet through us with our source
> > address?
>
> Does it concern with IPsec or fragmentation?
> It might be netfiler stuff. 

Well it means that you can't make certain assumptions in the
xfrm code.  For example, you cannot rely on the ordering of
extension headers since the original sender may have applied
a different ordering mechanism.

But I don't think it poses any security risks to the current
xfrm6 code so we can just leave that as undefined behaviour.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
