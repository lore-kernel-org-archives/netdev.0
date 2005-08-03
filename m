From: Miika Komu <miika@iki.fi>
Subject: Re: [Hipsec] Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Wed, 3 Aug 2005 23:57:24 +0300 (EEST)
Message-ID: <Pine.GSO.4.58.0508032319000.3957__21545.329099945$1123102999$gmane$org@kekkonen.cs.hut.fi>
References: <1122984099.1214.142.camel@odysse>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        infrahip@HIIT.FI, hipl-users@freelists.org, hipsec@ietf.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Diego Beltrami <diego.beltrami@HIIT.FI>
In-Reply-To: <1122984099.1214.142.camel@odysse>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Aug 2005, Diego Beltrami wrote:

Hi Herbert and others,

(sorry for the late comments - I am still on a holiday :)

> after sending the first version of BEET patch and having received a
> valuable feedback and after the discussion based upon the BEET design,
> we now send the new BEET patch which allows for BEET to work without the
> inter-family transform (i.e. inner address family different than outer
> address family).
> ...
>
> As it was originally designed the BEET patch at the moment works for
> only ESP protocol.
> As Pekka Nikader mentioned in one reply [1]: "[...] defining BEET mode
> for AH might be pretty tricky. [...] it probably would require some
> careful thinking to define the exact semantics, like what addresses
> (inner or outer)  are covered by the AH integrity protection, what does
> the integrity  protection really assert, etc. ".
>
> As previously written, the inter-family transform has been left out at
> the moment since the xfrm architecture doesn't support it. As a result,
> as soon as the xfrm architecture will be enhanced, the inter-family case
> will be properly included as, for example, it can be useful for
> supporting HIP over IPv4 network. But, as already mentioned, this would
> require more work in properly designing the xfrm architecture (thing
> which we consider necessary in order to make xfrm as generic as
> possible).

Based on the comments from Pekka Nikander, it seems like to me that
generalizing XFRM to support AH with different inner and outer families
may not very useful (a). On the other hand, the different inner and outer
families for BEET is *extremely* useful (b). Excluding this support from
BEET restricts the HIP implementations and applications quite radically.

My own thinking logic tells me the (a) + (b) equals to supporting
different inner and outer families in BEET in the way it is implemented
currently.  Don't fix it if it ain't broken!)

We have tested that the BEET with different inner and outer addresses does
not break anything. Further, if you don't need it, you don't have to
compile it in :) Later, if AH seems really useful with different inner and
outer families, or a new XYZ header is introduced, we can refactor the
architecture for greater modularity. Even then, the XFRM/PFKEY APIs
should remain the same.

So, I'd vote for the original BEET patch, but of course it is up to you to
decide. The BEET support is the minimal support required from the kernel
in order for a usepace HIP implementation to work, and it would make both
HIP implementors and users life much more easier :) Additionally, we would
gain also more experience from using mixed inner and outer families within
the XFRM architecture.

-- 
Miika Komu              miika@iki.fi          http://www.iki.fi/miika/
