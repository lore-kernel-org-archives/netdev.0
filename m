From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 13/30] net: Don't do pointless kmalloc return value casts in zd1211 driver
Date: Fri, 31 Aug 2007 17:30:18 +0800
Message-ID: <E1IR2pW-0007T2-00@gondolin.me.apana.org.au>
References: <9a8748490708301320o49d8e794vc5c37ffc938006f1@mail.gmail.com>
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (Jesper Juhl),
	Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9a8748490708301320o49d8e794vc5c37ffc938006f1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 30/08/2007, Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org> wrote:
>> Jesper Juhl wrote:
>> > Since kmalloc() returns a void pointer there is no reason to cast
>> > its return value.
>> > This patch also removes a pointless initialization of a variable.
>>
>> NAK: adds a sparse warning
>> zd_chip.c:116:15: warning: implicit cast to nocast type
>>
> Ok, I must admit I didn't check with sparse since it seemed pointless
> - we usually never cast void pointers to other pointer types,
> specifically because the C language nicely guarantees that the right
> thing will happen without the cast.  Sometimes we have to cast them to
> integer types, su sure we need the cast there.   But what on earth
> makes a "zd_addr_t *" so special that we have to explicitly cast a
> "void *" to that type?
> 
> I see it's defined as
>  typedef u32 __nocast zd_addr_t;
> in drivers/net/wireless/zd1211rw/zd_types.h , but why the __nocast ?

Nevermind the __nocast, this looks like a bug in sparse.  Just
because a base type is __nocast, sparse shouldn't infer that a
pointer to it should also be __nocast.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
