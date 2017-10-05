From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Wed, 04 Oct 2017 21:37:58 -0700 (PDT)
Message-ID: <20171004.213758.2210486785503998906.davem@davemloft.net>
References: <20171003052643.GB22750@gondor.apana.org.au>
        <20171003224505.GE19750@localhost.localdomain>
        <20171005034054.GB31996@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, baijiaju1990-9Onoh4P/yGk@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171005034054.GB31996-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Thu, 5 Oct 2017 11:40:54 +0800

> On Tue, Oct 03, 2017 at 07:45:06PM -0300, Marcelo Ricardo Leitner wrote:
>>
>> > Usually if you're invoking setkey from a non-sleeping code-path
>> > you're probably doing something wrong.
>> 
>> Usually but not always. There are 3 calls to that function on SCTP
>> code:
>> - pack a cookie, which is sent on an INIT_ACK packet to the client
>> - unpack the cookie above, after it is sent back by the client on a
>>   COOKIE_ECHO packet
>> - send a chunk authenticated by a hash
> 
> I'm not talking about the code-path in question.  I'm talking
> about the function which generates the secret key in the first
> place.  AFAICS that's only called in GFP_KERNEL context.  What
> am I missing?

The setkey happens in functions like sctp_pack_cookie() and
sctp_unpack_cookie(), which seems to run from software interrupts.
