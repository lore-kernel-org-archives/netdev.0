From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
	in transport mode
Date: Tue, 7 Jul 2009 09:40:08 +0800
Message-ID: <20090707014008.GA27100@gondor.apana.org.au>
References: <20090622090731.GA22496@gondor.apana.org.au> <20090630070036.GA16225@gondor.apana.org.au> <20090630140835.GA20811@gondor.apana.org.au> <20090706.183029.82831402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christophe@saout.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45983 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753616AbZGGBkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:40:14 -0400
Content-Disposition: inline
In-Reply-To: <20090706.183029.82831402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 06:30:29PM -0700, David Miller wrote:
> 
> Ugly solution or not I don't like this patch because it requires
> userspace to set this new attribute just to get correct checksums.
> 
> Can't we just detect the "came through remote peer" situation and
> just do the checksum fixup in that case?  Anything that doesn't
> require use changes, and as you've implemented it the user change
> is only possible with netlink IPSEC users.

Hmm I deliberately didn't want to have this as the default because
I want whoever that enables it to think about the implications.
Having it on by default means that people will just set this up
without realising that they're leaving the packet unprotected by
checksums for a fraction of the path.

As I explained, it's almost impossible to use this without leaving
the packet unprotected at least in one direction.

Having said that I'm fine with turning this into a sysctl or some
global setting that's easier to enable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
