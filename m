From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 09/17] Tools: hv: Represent the ipv6 mask using CIDR
 notation
Date: Tue, 24 Jul 2012 18:01:09 +0200
Message-ID: <20120724160108.GA13749@x1.osrc.amd.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-9-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org,
	ben@decadent.org.uk
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1343145701-3691-9-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2012 at 09:01:33AM -0700, K. Y. Srinivasan wrote:
> Transform ipv6 subnet information to CIDR notation.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  tools/hv/hv_kvp_daemon.c |   45 +++++++++++++++++++++++++++++++++++----------
>  1 files changed, 35 insertions(+), 10 deletions(-)
> 
> diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
> index 2c24ebf..007e698 100644
> --- a/tools/hv/hv_kvp_daemon.c
> +++ b/tools/hv/hv_kvp_daemon.c
> @@ -491,6 +491,15 @@ done:
>  	return;
>  }
>  
> +static unsigned int hweight32(unsigned int *w)
> +{
> +	unsigned int res = *w - ((*w >> 1) & 0x55555555);
> +	res = (res & 0x33333333) + ((res >> 2) & 0x33333333);
> +	res = (res + (res >> 4)) & 0x0F0F0F0F;
> +	res = res + (res >> 8);
> +	return (res + (res >> 16)) & 0x000000FF;
> +}

What's wrong with the hweight32 version we have already in
<include/asm-generic/bitops/const_hweight.h> which you can include by
simply by including <asm-generic/bitops.h>?

-- 
Regards/Gruss,
Boris.
