From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] accounting unit and variable
Date: Tue, 13 Nov 2007 19:55:49 -0800 (PST)
Message-ID: <20071113.195549.181119456.davem@davemloft.net>
References: <47264F3E.3080306@redhat.com>
	<20071109123420.GD27984@gondor.apana.org.au>
	<473A6B11.7090208@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	satoshi.oshima.fk@hitachi.com, andi@firstfloor.org,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	yoshfuji@linux-ipv6.org, yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757676AbXKNDzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 22:55:50 -0500
In-Reply-To: <473A6B11.7090208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hideo AOKI <haoki@redhat.com>
Date: Tue, 13 Nov 2007 22:27:13 -0500

> Herbert Xu wrote:
> > On Mon, Oct 29, 2007 at 05:23:10PM -0400, Hideo AOKI wrote:
> >>  
> >> +#define SK_DATAGRAM_MEM_QUANTUM ((int)PAGE_SIZE)
> >> +
> >> +static inline int sk_datagram_pages(int amt)
> >> +{
> >> +	return DIV_ROUND_UP(amt, SK_DATAGRAM_MEM_QUANTUM);
> >> +}
> > 
> > Does this really have to be int? Unsigned would let the compiler
> > optimise this to a simple shift.
> 
> Thank you for the comment.
> 
> This inline function is used to calculate the first argument of atomic_add()
> and atomic_sub(). Since the argument is int, I believe that using int is
> better than using unsigned int.

If you know the values will always be positive, as you will know here,
it is OK to us unsigned int here and avoids the unacceptable expensive
divide instruction.

Please fix this.
