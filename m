From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [2.6 patch] drivers/net/wireless/ipw2200.c: fix an array overun
Date: Tue, 14 Mar 2006 11:05:36 +0800
Message-ID: <1142305536.2622.35.camel@debian.sh.intel.com>
References: <20060311034258.GJ21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932535AbWCNDMy@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060311034258.GJ21864@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-03-11 at 04:42 +0100, Adrian Bunk wrote:
> This patch fixes a big array overun found by the Coverity checker.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> --- linux-2.6.16-rc5-mm3-full/drivers/net/wireless/ipw2200.c.old	2006-03-11 02:41:23.000000000 +0100
> +++ linux-2.6.16-rc5-mm3-full/drivers/net/wireless/ipw2200.c	2006-03-11 02:42:04.000000000 +0100
> @@ -9956,9 +9956,8 @@ static int ipw_ethtool_set_eeprom(struct
>  		return -EINVAL;
>  	mutex_lock(&p->mutex);
>  	memcpy(&p->eeprom[eeprom->offset], bytes, eeprom->len);
> -	for (i = IPW_EEPROM_DATA;
> -	     i < IPW_EEPROM_DATA + IPW_EEPROM_IMAGE_SIZE; i++)
> -		ipw_write8(p, i, p->eeprom[i]);
> +	for (i = 0; i < IPW_EEPROM_IMAGE_SIZE; i++)
> +		ipw_write8(p, i + IPW_EEPROM_DATA, p->eeprom[i]);
>  	mutex_unlock(&p->mutex);
>  	return 0;
>  }

Acked-by: Zhu Yi <yi.zhu@intel.com>

Thanks,
-yi
