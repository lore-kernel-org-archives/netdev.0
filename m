From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: MAX_SKB_FRAGS and GRO
Date: Tue, 9 Feb 2010 09:21:35 +1100
Message-ID: <20100208222135.GA14188@gondor.apana.org.au>
References: <20100208100306.GQ32246@kryten> <20100208124704.GA8538@gondor.apana.org.au> <alpine.WNT.2.00.1002080936180.6892@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anton Blanchard <anton@samba.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"divy@chelsio.com" <divy@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43054 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751909Ab0BHWVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 17:21:51 -0500
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1002080936180.6892@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 08, 2010 at 09:41:58AM -0800, Brandeburg, Jesse wrote:
>  
> > In fact I think the ixgbe code may be broken as it is since it's
> > not marking RSC packets in any way to prevent them from being
> > forwarded through another interface.
> 
> Herbert, what are we missing? Is there some interface for us to do what 
> you describe?  do we need to set DODGY?

The problem is that AFAIK RSC does not impose enough restrictions
on what is merged.  This means that information is lost during the
merge process.  IOW if the merged packet is forwarded we cannot
regenerate the original fragments exactly.

Therefore whenever bridging/routing is used on that interface RSC
must be turned off.

The easiest way to do this is to do what LRO does, which is to
set gso_type to zero and gso_size non-zero.  Of course you'll
also need to use the LRO toggle to control whether RSC is enabled
or not.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
