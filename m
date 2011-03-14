From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC v2 PATCH 1/9] crypto: authencesn - Add algorithm to
	handle IPsec extended sequence numbers
Date: Mon, 14 Mar 2011 17:39:07 +0800
Message-ID: <20110314093907.GA25957@gondor.apana.org.au>
References: <20110308100407.GB31402@secunet.com> <20110308100458.GC31402@secunet.com> <20110313063017.GA10849@gondor.apana.org.au> <20110314083741.GN31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alex Badea <abadea@ixiacom.com>,
	Andreas Gruenbacher <agruen@suse.de>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110314083741.GN31402@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2011 at 09:37:41AM +0100, Steffen Klassert wrote:
> On Sun, Mar 13, 2011 at 02:30:17PM +0800, Herbert Xu wrote:
> > On Tue, Mar 08, 2011 at 11:04:58AM +0100, Steffen Klassert wrote:
> > >
> > > +	return crypto_authenc_esn_genicv(req, iv, CRYPTO_TFM_REQ_MAY_SLEEP);
> > 
> > BTW, we should get rid of these MAY_SLEEP flags.  Originally I
> > included them for the IPsec encryption path because that happens
> > to be sleepable. We should instead be getting it from the request
> > itself.
> > 
> 
> Not sure if I get you right, but we do not set this flag here.
> We use it to mask the flags we got from the request, so we pass
> this flag to the ahash algorithm just if it was set by the
> original aead request.

Indeed you are right.  As long as it is only a mask and only
used on the sync path it should be OK.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
