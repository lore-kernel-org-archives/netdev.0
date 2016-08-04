From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Buggy rhashtable walking
Date: Thu, 4 Aug 2016 15:18:47 +0800
Message-ID: <20160804071846.GA773@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi:

While working on rhashtable I noticed that wireless is walking
rhashtables by hand using rht_for_each_*.  You must not do that
as an rhashtable can entail multiple hash tables when resizing.
If you walk it by hand then you may end up missing entries.

The correct way to do it is to use the rhashtable walk interface.
However, even this comes with the caveat that a given entry may
show up multiple times.  So if you cannot handle that then you
must construct your own data structure outside of rhashtable, like
we do in IPsec.

So the question is can wireless handle seeing an entry multiple
times? In particular, __ieee80211_rx_handle_packet would appear
to process the same packet multiple times if this were to happen.

Cheers,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
