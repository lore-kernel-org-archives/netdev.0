From: David Miller <davem@davemloft.net>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Sun, 08 Feb 2009 22:03:57 -0800 (PST)
Message-ID: <20090208.220357.261414983.davem@davemloft.net>
References: <20090206054541.GA4954@gondor.apana.org.au>
	<b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
	<20090209055848.GA3889@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff.chua.linux@gmail.com, rjw@sisk.pl,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbZBIGEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 01:04:04 -0500
In-Reply-To: <20090209055848.GA3889@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Feb 2009 16:58:48 +1100

> On Fri, Feb 06, 2009 at 07:35:50PM +0800, Jeff Chua wrote:
> >
> > > Did you change the kernel on the other side during these tests?
> > 
> > No. Was hoping that the traces would show where it hang for the good
> > and bad trace.
> 
> Then the problem isn't my patch at all.  My patch only affects
> the side sending the urgent data, according to your straces, rlogin
> is only receiving urgent data, not sending it.  So the patch cannot
> have an affect.

Hmmm... let's figure out exactly what's going on here.

I would expect to see the URG packets from rlogin not rlogind, from
things like hitting Ctrl-C etc.

On the other hand, I can't imagine what the server, rlogind, would be
sending URGs out for.

So I would say that it is more likely to be rlogin sending the
URG packets.
