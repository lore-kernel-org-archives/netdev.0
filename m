From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Wed, 30 Mar 2016 21:55:21 +0800
Message-ID: <20160330135521.GA19423@gondor.apana.org.au>
References: <56F9941A.3080501@candelatech.com>
 <56FAAA6D.3070806@candelatech.com>
 <1459329252.2055.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1459329252.2055.1.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2016 at 11:14:12AM +0200, Johannes Berg wrote:
> On Tue, 2016-03-29 at 09:16 -0700, Ben Greear wrote:
> > Looks like rhashtable has too much policy in it to properly deal with
> > cases where there are too many hash collisions, so I am going to work
> > on reverting it's use in mac80211.
> 
> I'm not really all that happy with that approach - can't we fix the
> rhashtable? It's a pretty rare corner case that many keys really are
> identical and no kind of hash algorithm, but it seems much better to
> still deal with it than to remove the rhashtable usage and go back to
> hand-rolling something.

Well to start with you should assess whether you really want to
hash multiple objects with the same key.  In particular, can an
adversary generate a large number of such objects?

If your conclusion is that yes you really want to do this, then
we have the parameter insecure_elasticity that you can use to
disable the rehashing based on chain length.

Cheers,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
