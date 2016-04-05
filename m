From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 5 Apr 2016 11:44:37 +0800
Message-ID: <20160405034437.GA9322@gondor.apana.org.au>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
 <20160404162818.14332.1076.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, jesse@kernel.org, alexander.duyck@gmail.com,
	edumazet@google.com, netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40665 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757157AbcDEDpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 23:45:15 -0400
Content-Disposition: inline
In-Reply-To: <20160404162818.14332.1076.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 09:31:21AM -0700, Alexander Duyck wrote:
> RFC 6864 states that the IPv4 ID field MUST NOT be used for purposes other
> than fragmentation and reassembly.  Currently we are looking at this field
> as a way of identifying what frames can be aggregated and  which cannot for
> GRO.  While this is valid for frames that do not have DF set, it is invalid
> to do so if the bit is set.

This justification is bogus.  GRO is a completely local optimisation
that should have zero visibility to third parties.  So it makes no
sense to talk about RFC compliance of GRO.  The Linux network stack
as a whole is subject to RFC compliance, but not GRO per se.
 
> In the case of the non-incrementing IP ID we will end up losing the data
> that the IP ID is fixed.  However as per RFC 6864 we should be able to
> write any value into the IP ID when the DF bit is set so this should cause
> minimal harm.

No we should not do that, at least not by default.  GRO was designed
to be completely lossless, that is its main advantage of the various
forms of LRO which preceded it.

If you lose that people will start asking it to be disabled for
routers/bridges and we'll be back in the same old mess that we
had with LRO.

So please do this properly and preserve the information in the packet.
As I said earlier all it takes is one single bit, like we do with ECN.
If you put it in the feature bit you'll also allow us to distinguish
between TSO drivers that produce fixed IDs vs. incrementing IDs.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
