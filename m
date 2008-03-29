From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/8] e1000e: limit EEPROM size accesses
Date: Fri, 28 Mar 2008 21:58:53 -0400
Message-ID: <47EDA25D.7040406@garzik.org>
References: <20080328161503.6562.44329.stgit@localhost.localdomain> <20080328161521.6562.23976.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59676 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755672AbYC2B67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:58:59 -0400
In-Reply-To: <20080328161521.6562.23976.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c  |    4 ++++
>  drivers/net/e1000e/es2lan.c |    4 ++++
>  2 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
> index f7e1619..9b46a00 100644
> --- a/drivers/net/e1000e/82571.c
> +++ b/drivers/net/e1000e/82571.c
> @@ -171,6 +171,10 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
>  		 * for setting word_size.
>  		 */
>  		size += NVM_WORD_SIZE_BASE_SHIFT;
> +
> +		/* EEPROM access above 16k is unsupported */
> +		if (size > 14)
> +			size = 14;
>  		nvm->word_size	= 1 << size;
>  		break;
>  	}
> diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
> index e3f4aee..2689e4b 100644
> --- a/drivers/net/e1000e/es2lan.c
> +++ b/drivers/net/e1000e/es2lan.c
> @@ -178,6 +178,10 @@ static s32 e1000_init_nvm_params_80003es2lan(struct e1000_hw *hw)
>  	 * for setting word_size.
>  	 */
>  	size += NVM_WORD_SIZE_BASE_SHIFT;
> +
> +	/* EEPROM access above 16k is unsupported */
> +	if (size > 14)
> +		size = 14;
>  	nvm->word_size	= 1 << size;

Is this 2.6.25-rc material?


