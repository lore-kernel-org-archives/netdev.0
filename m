From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 10/34]bnx2x: Compilation issue on IA64
Date: Wed, 14 Jan 2009 17:07:04 +0000
Message-ID: <1231952824.3010.29.camel@achroite>
References: <1231951391.11301.131.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:43941 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753291AbZANRHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:07:11 -0500
In-Reply-To: <1231951391.11301.131.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 18:43 +0200, Eilon Greenstein wrote:
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/bnx2x_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 4993707..ba56d1c 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -1199,7 +1199,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
>  
>  #ifdef BNX2X_STOP_ON_ERROR
>  	fp->tpa_queue_used |= (1 << queue);
> -#ifdef __powerpc64__
> +#if (defined __powerpc64__) || (defined _ASM_IA64_TYPES_H)
>  	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
>  #else
>  	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",

Or you could cast the value to unsigned long long and remove this
fragile #ifdef.

Maybe <linux/types.h> should define format strings like C99's PRIx64..

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

