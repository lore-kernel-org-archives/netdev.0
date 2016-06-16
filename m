From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH] net: sfc: avoid -Wtype-limits warning
Date: Thu, 16 Jun 2016 11:31:52 +0100
Message-ID: <3f85b364-6913-1ed5-0bc0-19aa2edc59f6@solarflare.com>
References: <20160615203122.3574513-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Martin Habets <mhabets@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615203122.3574513-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/06/16 21:31, Arnd Bergmann wrote:
> When building with -Wextra, we get a harmless warning from the
> EFX_EXTRACT_OWORD32 macro:
> 
> ethernet/sfc/farch.c: In function 'efx_farch_test_registers':
> ethernet/sfc/farch.c:119:30: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> ethernet/sfc/farch.c:124:144: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> ethernet/sfc/farch.c:124:392: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> ethernet/sfc/farch.c:124:731: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> 
> The macro and the caller are both correct, but we can avoid the
> warning by changing the index variable to a signed type.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Bert Kenward <bkenward@solarflare.com>

> ---
>  drivers/net/ethernet/sfc/farch.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
> index 133e9e35be9e..4c83739d158f 100644
> --- a/drivers/net/ethernet/sfc/farch.c
> +++ b/drivers/net/ethernet/sfc/farch.c
> @@ -104,7 +104,8 @@ int efx_farch_test_registers(struct efx_nic *efx,
>  			     const struct efx_farch_register_test *regs,
>  			     size_t n_regs)
>  {
> -	unsigned address = 0, i, j;
> +	unsigned address = 0;
> +	int i, j;
>  	efx_oword_t mask, imask, original, reg, buf;
>  
>  	for (i = 0; i < n_regs; ++i) {
> 
