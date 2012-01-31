From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtlwifi/rtl8192c: in _rtl92c_phy_calculate_bit_shift
 remove comparing bitmask against 1
Date: Mon, 30 Jan 2012 23:37:20 -0800
Message-ID: <1327995440.1804.16.camel@joe2Laptop>
References: <1327993863-6810-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com, paul.gortmaker@windriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Devendra.Naga" <devendra.aaru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [206.117.179.246] ([206.117.179.246]:57731 "EHLO labridge.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752015Ab2AaHhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 02:37:36 -0500
In-Reply-To: <1327993863-6810-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 02:11 -0500, Devendra.Naga wrote:
> From: "Devendra.Naga" <devendra.aaru@gmail.com>
[]
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
[]
> @@ -177,7 +177,7 @@ u32 _rtl92c_phy_calculate_bit_shift(u32 bitmask)
>  	u32 i;
>  
>  	for (i = 0; i <= 31; i++) {
> -		if (((bitmask >> i) & 0x1) == 1)
> +		if ((bitmask >> i) & 0x1)
>  			break;
>  	}
>  	return i;

Perhaps this is simpler and faster:

{
	u32 rtn = (u32)ffs((int)bitmask);
	if (rtn)
		return rtn - 1;
	return 32;
}
