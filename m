From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Wed, 23 Jan 2013 10:46:41 -0500 (EST)
Message-ID: <1454517509.108827.1358956001908.JavaMail.root@elliptictech.com>
References: <20130123173510.14986sla4qsstz8k@www.dalek.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	linux-crypto@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20130123173510.14986sla4qsstz8k@www.dalek.fi>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: linux-kernel@vger.kernel.org, "Herbert Xu" <herbert@gondor.apana.org.au>, "David Miller" <davem@davemloft.net>,
> linux-crypto@vger.kernel.org, "Steffen Klassert" <steffen.klassert@secunet.com>, netdev@vger.kernel.org
> Sent: Wednesday, 23 January, 2013 10:35:10 AM
> Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent, and testmgr build issues
> 
> Quoting Tom St Denis <tstdenis@elliptictech.com>:
> 
> > ----- Original Message -----
> >> From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
> >> To: "Tom St Denis" <tstdenis@elliptictech.com>
> >> Cc: linux-kernel@vger.kernel.org, "Herbert Xu"
> >> <herbert@gondor.apana.org.au>, "David Miller"
> >> <davem@davemloft.net>,
> >> linux-crypto@vger.kernel.org, "Steffen Klassert"
> >> <steffen.klassert@secunet.com>, netdev@vger.kernel.org
> >> Sent: Wednesday, 23 January, 2013 9:36:44 AM
> >> Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch
> >> issues, indent, and testmgr build issues
> >>
> >> Quoting Tom St Denis <tstdenis@elliptictech.com>:
> >>
> >> > Hey all,
> >> >
> >> > Here's an updated patch which addresses a couple of build issues
> >> > and
> >> > coding style complaints.
> >> >
> >> > I still can't get it to run via testmgr I get
> >> >
> >> > [  162.407807] alg: No test for cmac(aes) (cmac(aes-generic))
> >> >
> >> > Despite the fact I have an entry for cmac(aes) (much like
> >> > xcbc(aes)...).
> >> >
> >> > Here's the patch to bring 3.8-rc4 up with CMAC ...
> >> >
> >> > Signed-off-by: Tom St Denis <tstdenis@elliptictech.com>
> >> >
> >> <snip>
> >> > diff --git a/include/uapi/linux/pfkeyv2.h
> >> > b/include/uapi/linux/pfkeyv2.h
> >> > index 0b80c80..d61898e 100644
> >> > --- a/include/uapi/linux/pfkeyv2.h
> >> > +++ b/include/uapi/linux/pfkeyv2.h
> >> > @@ -296,6 +296,7 @@ struct sadb_x_kmaddress {
> >> >  #define SADB_X_AALG_SHA2_512HMAC	7
> >> >  #define SADB_X_AALG_RIPEMD160HMAC	8
> >> >  #define SADB_X_AALG_AES_XCBC_MAC	9
> >> > +#define SADB_X_AALG_AES_CMAC_MAC	10
> >> >  #define SADB_X_AALG_NULL		251	/* kame */
> >> >  #define SADB_AALG_MAX			251
> >>
> >> Should these values be based on IANA assigned IPSEC AH transform
> >> identifiers?
> >>
> >> https://www.iana.org/assignments/isakmp-registry/isakmp-registry.xml#isakmp-registry-6
> >
> > There is no CMAC entry apparently ... despite the fact that CMAC is
> > a proposed RFC standard for IPsec.
> >
> > It might be safer to move that to 14 since it's currently
> > unassigned
> > and then go through whatever channels are required to allocate it.
> > Mostly this affects key setting.  So this means my patch would
> > break
> > AH_RSA setkey calls (which the kernel doesn't support anyways).
> >
> 
> Problem seems to be that PFKEYv2 does not quite work with IKEv2, and
> XFRM API should be used instead. There is new numbers assigned for
> IKEv2:
> https://www.iana.org/assignments/ikev2-parameters/ikev2-parameters.xml#ikev2-parameters-7
> 
> For new SADB_X_AALG_*, I'd think you should use value from "Reserved
> for private use" range. Maybe 250?
> 
> But maybe better solution might be to not make AES-CMAC (or other new
> algorithms) available throught PFKEY API at all, just XFRM?

This is where I'm getting out of my area of knowledge.  Internally we use the "ip" tool to set SAs and that's about all I know about key management for IPsec in the kernel.

For testing we only use static keys since IKE is not part of our hardware offering anyways.

As long as I can use "ip" to set the keys I'm ok with whatever changes we make to this entry.

Tom
