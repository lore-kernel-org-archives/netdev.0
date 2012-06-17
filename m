From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 4/5] powerpc: bitops: Introduce {clear,set}_bit_le()
Date: Mon, 18 Jun 2012 07:49:35 +1000
Message-ID: <1339969775.9220.241.camel@pasglop>
References: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
	 <20120613130438.b1cd04db.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, bhutchings@solarflare.com,
	grundler@parisc-linux.org, arnd@arndb.de, avi@redhat.com,
	mtosatti@redhat.com, linux-net-drivers@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, kvm@vger.kernel.org,
	takuya.yoshikawa@gmail.com
To: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120613130438.b1cd04db.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-13 at 13:04 +0900, Takuya Yoshikawa wrote:
> From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
> 
> Needed to replace test_and_set_bit_le() in virt/kvm/kvm_main.c which is
> being used for this missing function.
> 
> Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

> ---
>  arch/powerpc/include/asm/bitops.h |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/bitops.h b/arch/powerpc/include/asm/bitops.h
> index efdc926..dc2cf9c 100644
> --- a/arch/powerpc/include/asm/bitops.h
> +++ b/arch/powerpc/include/asm/bitops.h
> @@ -288,6 +288,16 @@ static __inline__ int test_bit_le(unsigned long nr,
>  	return (tmp[nr >> 3] >> (nr & 7)) & 1;
>  }
>  
> +static inline void set_bit_le(int nr, void *addr)
> +{
> +	set_bit(nr ^ BITOP_LE_SWIZZLE, addr);
> +}
> +
> +static inline void clear_bit_le(int nr, void *addr)
> +{
> +	clear_bit(nr ^ BITOP_LE_SWIZZLE, addr);
> +}
> +
>  static inline void __set_bit_le(int nr, void *addr)
>  {
>  	__set_bit(nr ^ BITOP_LE_SWIZZLE, addr);
