From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Thu, 09 Sep 2004 10:27:36 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909.102736.94408944.yoshfuji@linux-ipv6.org>
References: <20040909000330.GA5581@gondor.apana.org.au>
	<20040909.092428.125540781.yoshfuji@linux-ipv6.org>
	<20040909011016.GA9238@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20040909011016.GA9238@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040909011016.GA9238@gondor.apana.org.au> (at Thu, 9 Sep 2004 11:10:16 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Thu, Sep 09, 2004 at 09:24:28AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > 
> > s/__constant_htons/htons/g here, please.
> 
> Good point.
> 
> > And, I think 
> >   u16 ecn = (iph->tos + 1) & INET_ECN_MASK;
> >   check += (u32)htons(0xfffb) + (u32)htons(ecn);
> 
> The second htons is less optimal than the shift because htons doesn't
> know that ecn is only a byte.  So it'll end up doing a full swap.

Not true; gcc is clever enough to produces same code, and my code looks better.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
