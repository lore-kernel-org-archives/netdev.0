From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/RFT 3/4] mac80211: use GSO for fragmentation
Date: Wed, 7 May 2008 15:10:26 +0800
Message-ID: <20080507071026.GA24407@gondor.apana.org.au>
References: <20080430124055.091382000@sipsolutions.net> <20080430130050.105344000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48458 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763555AbYEGHKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 03:10:31 -0400
Content-Disposition: inline
In-Reply-To: <20080430130050.105344000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2008 at 02:40:58PM +0200, Johannes Berg wrote:
> This patch makes mac80211 use the GSO infrastructure for segmentation,
> but not really all of it because we do not register a protocol handler
> (nor can do that easily since a lot of functions need to be done before
> segmentation and another bunch afterwards, and we need to keep rcu-
> protected structures for both.)

Your idea of using skb_segment to remove duplicate code is great.

However, using skb->gso_skb for the push-back doesn't work.  For
example, what is going to happen when I enable software GSO on a
wireless device and then send a real GSO packet to it where each
GSO fragment also required wireless fragmentation?

I suggest that you just use skb_segment for the actual fragmentation
but keep the original infrastructure for handling the fragments.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
