From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Wed, 23 Jan 2013 08:41:13 +0100
Message-ID: <20130123074113.GH9147@secunet.com>
References: <537355069.94465.1358772395763.JavaMail.root@elliptictech.com>
 <436404741.94502.1358773048618.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <436404741.94502.1358773048618.JavaMail.root@elliptictech.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc netdev@vger.kernel.org)

On Mon, Jan 21, 2013 at 07:57:28AM -0500, Tom St Denis wrote:
> Hey all,
> 
> Here's an updated patch which addresses a couple of build issues and coding style complaints.  
> 
> I still can't get it to run via testmgr I get 
> 
> [  162.407807] alg: No test for cmac(aes) (cmac(aes-generic))
> 
> Despite the fact I have an entry for cmac(aes) (much like xcbc(aes)...).
> 
> Here's the patch to bring 3.8-rc4 up with CMAC ...
> 

As already pointed out by David Dillow, the above comments should go
after the '---' separator. Please use the subject line and commit
message from the previous version of this patch when you resend,
this was ok.

> Signed-off-by: Tom St Denis <tstdenis@elliptictech.com>
> 
> ---
>  crypto/Kconfig               |   8 ++
>  crypto/Makefile              |   1 +
>  crypto/cmac.c                | 317 +++++++++++++++++++++++++++++++++++++++++++
>  crypto/testmgr.c             |   9 ++
>  crypto/testmgr.h             |  52 +++++++
>  include/uapi/linux/pfkeyv2.h |   1 +
>  net/xfrm/xfrm_algo.c         |  17 +++
>  7 files changed, 405 insertions(+)
>  create mode 100644 crypto/cmac.c
> 
> diff --git a/crypto/Kconfig b/crypto/Kconfig
> index 4641d95..5ac2c7f 100644
> --- a/crypto/Kconfig
> +++ b/crypto/Kconfig
> @@ -301,6 +301,14 @@ config CRYPTO_XCBC
>  		http://csrc.nist.gov/encryption/modes/proposedmodes/
>  		 xcbc-mac/xcbc-mac-spec.pdf
>  
> +config CRYPTO_CMAC
> +	tristate "CMAC support"
> +	depends on EXPERIMENTAL

CONFIG_EXPERIMENTAL is going to be removed in linux-next,
please remove this dependency.

> +	select CRYPTO_HASH
> +	select CRYPTO_MANAGER
> +	help
> +	  NIST CMAC cipher based MAC
> +

Please add some more information to the help text. Everybody who knows
what a 'NIST CMAC cipher based MAC' is will not need this help text, all
the others are left with almost no information. This help text is for
users in the first place, not for developers. So it should contain some
informations about this cipher and/or some pointers where to find
informations.

Please Cc me on your next version because we plan to route your
patch via the ipsec-next tree into the mainline.

Thanks!
