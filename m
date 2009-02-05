From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Fri, 6 Feb 2009 10:52:23 +1100
Message-ID: <20090205235223.GB1929@gondor.apana.org.au>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com> <20090205.152906.221253085.davem@davemloft.net> <alpine.LFD.2.00.0902051530520.3048@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57425 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752805AbZBEXwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:52:36 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0902051530520.3048@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 03:32:20PM -0800, Linus Torvalds wrote:
> 
> Why is there even any discussion?
> 
> URG is broken as a concept, no sane/modern use case exists. It's totally 
> uninteresting _except_ as a "legacy binary" issue, so
> 
>  - there's no point in trying to "improve" it.
> 
>  - even just a whiff of "breaks legacy app" just says "revert it".
> 
> No?

It's more complex than that.  We'll need to do exactly this in
the future in order to support IPv6 jumbograms because that's
the only way to use the 16-bit urgent pointer in a packet bigger
than 64K.  It's also what RFC2675 (http://tools.ietf.org/html/rfc2675,
section 5.2) prescribes.

IPv6 jumbograms are absolutely required if we ever want to move
beyond 10Gb/s Ethernet.

But as we're still struggling with 10Gb/s Ethernet, I'm fine with
a revert for now while we look for a fix for rlogin.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
