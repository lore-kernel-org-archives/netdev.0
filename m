From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 21:26:23 +0800
Message-ID: <20100331132622.GA13908@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi> <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi> <20100331131131.GA13793@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:59726 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757451Ab0CaN0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:26:37 -0400
Content-Disposition: inline
In-Reply-To: <20100331131131.GA13793@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 09:11:31PM +0800, Herbert Xu wrote:
> 
> > This is a consistent definition of the semantics everywhere tables
> > are flushed (not just in Linux)..
> 
> Please give specific examples in the kernel.

In fact the previous behaviour is also consistent with RFC2367:

3.1.9 SADB_FLUSH

   The SADB_FLUSH message causes the kernel to delete all entries in its
   key table for a certain sadb_msg_satype.  Only the base header is
   required for a flush message.  If sadb_msg_satype is filled in with a
   specific value, only associations of that type are deleted.  If it is
   filled in with SADB_SATYPE_UNSPEC, ALL associations are deleted.

     The messaging behavior for SADB_FLUSH is:

           Send an SADB_FLUSH message from a user process to the kernel.

           <base>

           The kernel will return an SADB_FLUSH message to all listening
           sockets.

           <base>

           The reply message happens only after the actual flushing
           of security associations has been attempted.

There is no special treatment for an empty DB.

Please send a revert.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
