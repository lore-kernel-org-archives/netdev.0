From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Fri, 12 Oct 2007 07:24:11 +0800
Message-ID: <20071011232411.GA21071@gondor.apana.org.au>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au> <20071011003638.GA27174@redhat.com> <20071011012520.GA13160@gondor.apana.org.au> <470E4AFA.60507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	esandeen@redhat.com, dmack@juniper.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2391 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752143AbXJKXYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 19:24:43 -0400
Content-Disposition: inline
In-Reply-To: <470E4AFA.60507@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 09:10:34AM -0700, Kok, Auke wrote:
> >>
> >> commit 416b5d10afdc797c21c457ade3714e8f2f75edd9
> >> Author: Auke Kok <auke-jan.h.kok@intel.com>
> >> Date:   Fri Jun 1 10:22:39 2007 -0700
> >>
> >>     e1000: disable polling before registering netdevice
> 
> this patch actually called napi_disable() in the probe routine which was wrong,
> but e100 does not do that. Nonetheless e100 doesn't call netif_carrier_off() and
> netif_stop_queue(), so to make e100 the same as e1000 we should probably do this,
> see below.

Back then we didn't have napi_disable at all.  That patch calls
netif_poll_disable which has different semantics.

> Dave, can you see if this resolves the issue for you? If so then we might want to
> push this to -stable.

The problem is with netif_poll so this patch probably won't help.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
