From: Steve French <smfrench@gmail.com>
Subject: Re: [PATCH 1/2] crypto: add CMAC support to CryptoAPI
Date: Mon, 8 Apr 2013 08:20:52 -0500
Message-ID: <CAH2r5mt=M9ZMQCUbMpYfwE6OY5PeEgDbSbh0q-rQ4ucyu6zeug@mail.gmail.com>
References: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
	<CADT32eLHBWoRMvnBWbEEEWfpQtsnivYSeSgyG95MhURVEgmgjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Shirish Pargaonkar <shirishpargaonkar@gmail.com>,
	jussi.kivilinna@iki.fi,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Network Development <netdev@vger.kernel.org>,
	Tom St Denis <tstdenis@elliptictech.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:51526 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935548Ab3DHNUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 09:20:54 -0400
Received: by mail-lb0-f172.google.com with SMTP id u10so5705390lbi.3
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 06:20:52 -0700 (PDT)
In-Reply-To: <CADT32eLHBWoRMvnBWbEEEWfpQtsnivYSeSgyG95MhURVEgmgjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This does look promising - AES_CMAC in the crypto libs would be very
helpful for SMB3 for cifs.ko (for the common cases when packet signing
is required, or network file system encryption is turned on for a
share).  Presumably with Windows 8 and Windows 2012 and some very
current NAS these are required.  Apparently AES_CMAC also is much
faster than the algorithms used in previous network file system
dialect levels as well, so will help performance, not just be more
secure.

This general crypto patch is much larger than the cifs.ko specific
patch I had been working on but perhaps it is because of optional
features.


> ---------- Forwarded message ----------
> From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
> Date: Mon, Apr 8, 2013 at 2:48 AM
> Subject: [PATCH 1/2] crypto: add CMAC support to CryptoAPI
> To: linux-crypto@vger.kernel.org
> Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, Tom St Denis <tstdenis@elliptictech.com>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>
>
>
> Patch adds support for NIST recommended block cipher mode CMAC to CryptoAPI.
>
> This work is based on Tom St Denis' earlier patch,
>  http://marc.info/?l=linux-crypto-vger&m=135877306305466&w=2
>
> Cc: Tom St Denis <tstdenis@elliptictech.com>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
> ---
>  crypto/Kconfig   |   11 ++
>  crypto/Makefile  |    1
>  crypto/cmac.c    |  315 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  crypto/tcrypt.c  |   11 ++
>  crypto/testmgr.c |   18 +++
>  crypto/testmgr.h |  125 +++++++++++++++++++++
>  6 files changed, 480 insertions(+), 1 deletion(-)
>  create mode 100644 crypto/cmac.c
>
> diff --git a/crypto/Kconfig b/crypto/Kconfig
> index 6cc27f1..c1142f3 100644
> --- a/crypto/Kconfig
> +++ b/crypto/Kconfig
> @@ -283,6 +283,17 @@ config CRYPTO_XTS
>
>  comment "Hash modes"
>
> +config CRYPTO_CMAC
> +       tristate "CMAC support"
> +       select CRYPTO_HASH
> +       select CRYPTO_MANAGER
> +       help
> +         Cipher-based Message Authentication Code (CMAC) specified by
> +         The National Institute of Standards and Technology (NIST).
> +
> +         https://tools.ietf.org/html/rfc4493
> +         http://csrc.nist.gov/publications/nistpubs/800-38B/SP_800-38B.pdf
>



--
Thanks,

Steve
