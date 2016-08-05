From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Buggy rhashtable walking
Date: Fri, 05 Aug 2016 08:16:53 +0200
Message-ID: <1470377813.2977.14.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
	 <20160804074546.GA996@gondor.apana.org.au>
	 (sfid-20160804_094611_627754_FBB091B2)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, tom@herbertland.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36276 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965694AbcHEGRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2016 02:17:02 -0400
In-Reply-To: <20160804074546.GA996@gondor.apana.org.au> (sfid-20160804_094611_627754_FBB091B2)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> So I'm going to fix this by consolidating identical objects into
> a single rhashtable entry which also lets us get rid of the
> insecure_elasticity setting.

Hm. Would you rather allocate a separate head entry for the hashtable,
or chain the entries?

(Luckily) the colliding key case practically never happens, and some
drivers don't even allow it, so that's perhaps something to keep in
mind for this. Perhaps we should just generally disallow it - but a few
people (hi Ben) would be really unhappy about that I guess.

I think this might affect more than one use of rhashtable in mac80211
now, since the mesh paths also use it.

johannes
