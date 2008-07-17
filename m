From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: [PATCH net-next 1/2] iwlwifi: compilation error when CONFIG_IWLWIFI_DEBUG is not set
Date: Thu, 17 Jul 2008 14:05:13 +0300
Message-ID: <1ba2fa240807170405i5f47b4e0m3cf9253dd8b7d169@mail.gmail.com>
References: <1216286365-11703-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yi.zhu@intel.com, reinette.chatre@intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.186]:18173 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755972AbYGQLFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 07:05:14 -0400
Received: by rn-out-0910.google.com with SMTP id k40so2030563rnd.17
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 04:05:14 -0700 (PDT)
In-Reply-To: <1216286365-11703-1-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2008 at 12:19 PM, Denis V. Lunev <den@openvz.org> wrote:
> CC [M]  drivers/net/wireless/iwlwifi/iwl-rfkill.o
> drivers/net/wireless/iwlwifi/iwl-led.c: In function 'iwl_led_brightness_set':
> drivers/net/wireless/iwlwifi/iwl-led.c:198: error: 'led_type_str' undeclared (first use in this function)
> drivers/net/wireless/iwlwifi/iwl-led.c:198: error: (Each undeclared identifier is reported only once
> drivers/net/wireless/iwlwifi/iwl-led.c:198: error: for each function it appears in.)
>
> The problem is that led_type_str is defined under CONFIG_IWLWIFI_DEBUG
> while IWL_DEBUG is a static inline function in this case. Replace it
> with macro.
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> ---
>  drivers/net/wireless/iwlwifi/iwl-debug.h |    8 ++------
>  1 files changed, 2 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/iwlwifi/iwl-debug.h
> index 5838480..d6d729e 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-debug.h
> +++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
> @@ -68,12 +68,8 @@ void iwl_dbgfs_unregister(struct iwl_priv *priv);
>  #endif
>
>  #else
> -static inline void IWL_DEBUG(int level, const char *fmt, ...)
> -{
> -}
> -static inline void IWL_DEBUG_LIMIT(int level, const char *fmt, ...)
> -{
> -}
> +#define IWL_DEBUG(level, fmt, args...)
> +#define IWL_DEBUG_LIMIT(level, fmt, args...)
>  #endif                         /* CONFIG_IWLWIFI_DEBUG */
>
ACK
Tomas
