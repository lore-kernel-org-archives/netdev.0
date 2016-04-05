From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 5 Apr 2016 12:32:09 +0800
Message-ID: <20160405043209.GA9822@gondor.apana.org.au>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
 <20160404162818.14332.1076.stgit@localhost.localdomain>
 <20160405034437.GA9322@gondor.apana.org.au>
 <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47030 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbcDEEcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:32:24 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 09:26:55PM -0700, Alexander Duyck wrote:
> 
> The problem is right now we are mangling the IP ID for outer headers
> on tunnels.  We end up totally ignoring the delta between the values
> so if you have two flows that get interleaved over the same tunnel GRO
> will currently mash the IP IDs for the two tunnels so that they end up
> overlapping.

Then it should be fixed.  I never reviewed those patches or I would
have objected at the time.

> The reason why I keep referencing RFC 6864 is because it specifies
> that the IP ID field must not be read if the DF bit is set, and that
> if we are manipulating headers we can handle the IP ID as though we
> are the transmitting station.  What this means is that if DF is not
> set we have to have unique values per packet, otherwise we can ignore
> the values if DF is set.

As I said GRO itself should not be visible.  The fact that it is
for tunnels is a bug.
 
> The question I would have is what are you really losing with increment
> from 0 versus fixed 0?  From what I see it is essentially just garbage
> in/garbage out.

GRO is meant to be lossless, that is, you should not be able to
detect its presence from the outside.  If you lose information then
you're breaking this rule and people will soon start asking for it
to be disabled in various situations.

I'm not against doing this per se but it should not be part of the
default configuration.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
