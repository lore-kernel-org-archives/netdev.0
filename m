From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: release hw semaphore after successfully writing
 EEPROM
Date: Mon, 29 Sep 2008 15:48:41 -0700
Message-ID: <48E15B49.4060205@intel.com>
References: <20080929215109.GA23380@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Arthur Jones <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47317 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbYI2Wsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 18:48:43 -0400
In-Reply-To: <20080929215109.GA23380@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


looks totally valid to me indeed!


Reviewed-by: Auke Kok <auke-jan.h.kok@intel.com>


Auke

Arthur Jones wrote:
> Since e1000e has been existance in linux-2.6, we've
> never released the hardware semaphore after a successful
> write to the SPI EEPROM.  I guess we don't write to
> SPI EEPROM much -- but those few of us that do appreciate
> it when we can later read from the EEPROM without having
> to reboot.
> 
> Found-by: Nick Van Fossen <Nick.VanFossen@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---
>  drivers/net/e1000e/lib.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
> index f1f4e9d..6492107 100644
> --- a/drivers/net/e1000e/lib.c
> +++ b/drivers/net/e1000e/lib.c
> @@ -2012,6 +2012,7 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
>  	}
>  
>  	msleep(10);
> +	nvm->ops.release_nvm(hw);
>  	return 0;
>  }
>  

