From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -mm2] net: Fix compiler-error on dgrs.c when !CONFIG_PCI
Date: Mon, 21 Nov 2005 07:40:01 +1100
Message-ID: <20051120204001.GA11043@gondor.apana.org.au>
References: <E1EdmMo-00020b-00@gondolin.me.apana.org.au> <438097D2.9020607@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, ashutosh.naik@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750804AbVKTUk2@vger.kernel.org>
To: Richard Knutsson <ricknu-0@student.ltu.se>
Content-Disposition: inline
In-Reply-To: <438097D2.9020607@student.ltu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 20, 2005 at 04:35:46PM +0100, Richard Knutsson wrote:
>
> >-#ifdef CONFIG_EISA
> >-	cardcount = eisa_driver_register(&dgrs_eisa_driver);
> >+	cardcount = dgrs_register_eisa();
> > 	if (cardcount < 0)
> > 		return cardcount;
> >-#endif
> >-	cardcount = pci_register_driver(&dgrs_pci_driver);
> >-	if (cardcount)
> >+	cardcount = dgrs_register_pci();
> >+	if (cardcount < 0) {
> Are you sure it should be "cardcount < 0" and not "cardcount"?

Yes if cardcount is >= 0 then the registration was successful.

> >+		dgrs_unregister_eisa();
> Why change the behaviour off this driver?

Because the driver was buggy.  When this function returns a non-zero
value, it must return the system to its original state.

That means if the EISA driver has already been registered then it must
be unregistered.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
