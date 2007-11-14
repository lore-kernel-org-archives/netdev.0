From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/5] accounting unit and variable
Date: Wed, 14 Nov 2007 11:45:50 +0800
Message-ID: <20071114034550.GA9624@gondor.apana.org.au>
References: <47264E2D.4080109@redhat.com> <47264F3E.3080306@redhat.com> <20071109123420.GD27984@gondor.apana.org.au> <473A6B11.7090208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1890 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756009AbXKNDq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 22:46:58 -0500
Content-Disposition: inline
In-Reply-To: <473A6B11.7090208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 10:27:13PM -0500, Hideo AOKI wrote:
> 
> Herbert Xu wrote:
> >> 
> >>+#define SK_DATAGRAM_MEM_QUANTUM ((int)PAGE_SIZE)
> >>+
> >>+static inline int sk_datagram_pages(int amt)
> >>+{
> >>+	return DIV_ROUND_UP(amt, SK_DATAGRAM_MEM_QUANTUM);
> >>+}
> >
> >Does this really have to be int? Unsigned would let the compiler
> >optimise this to a simple shift.
> 
> Thank you for the comment.
> 
> This inline function is used to calculate the first argument of atomic_add()
> and atomic_sub(). Since the argument is int, I believe that using int is
> better than using unsigned int.

That doesn't really answer my question.  Is this quantity ever
negative? If not you should make it unsigned for the reason I
gave above.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
