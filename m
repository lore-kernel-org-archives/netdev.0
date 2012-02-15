From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v3] rtlwifi: rtl8192se firmware load can overflow target
 buffer
Date: Wed, 15 Feb 2012 13:55:26 -0500
Message-ID: <20120215185525.GE4379@tuxdriver.com>
References: <1328833192-10681-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1328833192-10681-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Is this a fix that should go to 3.3?

On Thu, Feb 09, 2012 at 06:19:52PM -0600, Larry Finger wrote:
> From: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> Define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE which represents the
> maximimum possible firmware file size. Use it in the definition
> of the buffer which receives the firmware file data.
> 
> Set RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE closer to the actual size of
> the firmware file, e.g., 90000 (down from hard coded 164000). The current
> size of rtlwifi/rtl8192sefw.bin is 88856.
> 
> Set max_fw_size to RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE for the size limit
> check. Fix the error case where max_fw_size is not cleared if the size
> limit check fails.
> 
> Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
>  drivers/net/wireless/rtlwifi/rtl8192se/fw.h |    3 ++-
>  drivers/net/wireless/rtlwifi/rtl8192se/sw.c |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
> index babe85d..b4afff6 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
> @@ -30,6 +30,7 @@
>  #define __REALTEK_FIRMWARE92S_H__
>  
>  #define RTL8190_MAX_FIRMWARE_CODE_SIZE		64000
> +#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE	90000
>  #define RTL8190_CPU_START_OFFSET		0x80
>  /* Firmware Local buffer size. 64k */
>  #define	MAX_FIRMWARE_CODE_SIZE			0xFF00
> @@ -217,7 +218,7 @@ struct rt_firmware {
>  	u8 fw_emem[RTL8190_MAX_FIRMWARE_CODE_SIZE];
>  	u32 fw_imem_len;
>  	u32 fw_emem_len;
> -	u8 sz_fw_tmpbuffer[164000];
> +	u8 sz_fw_tmpbuffer[RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE];
>  	u32 sz_fw_tmpbufferlen;
>  	u16 cmdpacket_fragthresold;
>  };
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
> index ca38dd9..345d752 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
> @@ -108,6 +108,7 @@ static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
>  	if (firmware->size > rtlpriv->max_fw_size) {
>  		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
>  			 "Firmware is too big!\n");
> +		rtlpriv->max_fw_size = 0;
>  		release_firmware(firmware);
>  		return;
>  	}
> @@ -232,7 +233,7 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
>  		return 1;
>  	}
>  
> -	rtlpriv->max_fw_size = sizeof(struct rt_firmware);
> +	rtlpriv->max_fw_size = RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE;
>  
>  	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
>  		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
> -- 
> 1.7.9
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
