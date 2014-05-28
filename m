From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 1/2] sfc: use 64-bit writes for PIO.
Date: Wed, 28 May 2014 18:48:57 +0400
Message-ID: <5385F759.8010408@cogentembedded.com>
References: <cover.1401268725.git.sshah@solarflare.com> <5385ABE5.9070406@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: Shradha Shah <sshah@solarflare.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:52122 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbaE1Osx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 10:48:53 -0400
Received: by mail-la0-f41.google.com with SMTP id e16so7521485lan.0
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 07:48:51 -0700 (PDT)
In-Reply-To: <5385ABE5.9070406@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2014 01:27 PM, Shradha Shah wrote:

> From: Jon Cooper <jcooper@solarflare.com>

> Patch to open-code the memory copy routines.
> 32bit writes over the PCI bus causes data corruption.

> Fixes:ee45fd92c739db5b7950163d91dfe5f016af6d24

    Same comment as in the patch #2

> orig-hg-hash: 853f313def1e5e9c733f980f2b4e6330a7d063ef

    What's this?

> Signed-off-by: Shradha Shah <sshah@solarflare.com>
> ---
>   drivers/net/ethernet/sfc/tx.c | 24 +++++++++++++++++++-----
>   1 file changed, 19 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
> index fa94753..bd6a4b8 100644
> --- a/drivers/net/ethernet/sfc/tx.c
> +++ b/drivers/net/ethernet/sfc/tx.c
> @@ -189,6 +189,20 @@ struct efx_short_copy_buffer {
>   	u8 buf[L1_CACHE_BYTES];
>   };
>
> +/* Copy in explicit 64-bit writes. */
> +static void efx_memcpy_64(void *dest, void *src, size_t len)
> +{
> +	uint64_t *src64 = src, *dest64 = dest;
> +	size_t i, l64 = len / 8;
> +
> +	WARN_ON_ONCE(len % 8 != 0);
> +	WARN_ON_ONCE(((u8 *)dest - (u8 *) 0) % 8 != 0);

    Be consistent with spaces after a typecast, please.

> +	BUILD_BUG_ON(sizeof(uint64_t) != 8);
> +
> +	for(i = 0; i < l64; ++i)
> +		dest64[i] = src64[i];
> +}
> +
>   /* Copy to PIO, respecting that writes to PIO buffers must be dword aligned.
>    * Advances piobuf pointer. Leaves additional data in the copy buffer.
>    */
[...]

WBR, Sergei
