From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] Revert "rtlwifi: rtl8188ee: enable MSI interrupts
 mode"
Date: Thu, 24 Apr 2014 01:25:38 -0500
Message-ID: <5358AE62.6050509@lwfinger.net>
References: <1398308924-15312-1-git-send-email-adam.lee@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
To: Adam Lee <adam.lee@canonical.com>, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:37533 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaDXGZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 02:25:40 -0400
In-Reply-To: <1398308924-15312-1-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 10:08 PM, Adam Lee wrote:
> This reverts commit 2a54eb5e1476426ee639bbfbe179b52342a0d82c.
>
> 94010fa0dd07e8b904e7c6b6589f15573008ab15 introduced MSI interrupts mode
> support, which seemed safe enough with RTL8188EE and RTL8723BE as
> RealTek's testing results, but some users reported their RTL8188EE
> modules could not connect to any wireless network after the MSI mode was
> enabled by Ubuntu 14.04.
>
> So, let's fallback to pin-based mode until rtlwifi's MSI support get
> good compatibility.
>
> BugLink: https://bugs.launchpad.net/bugs/1310512
> Signed-off-by: Adam Lee <adam.lee@canonical.com>

ACK for both of these patches. I thought I had tested these patches when they 
first came through, but obviously I did not. I do not know which Realtek 
engineers you consulted, but they failed to supply you with the MSI handler. The 
Realsil group that actually does the coding for the PCI-based devices have 
supplied such a routine along with the driver for the RTL8192EE devices. With 
the handler, MSI does work. After I integrate that handler into rtlwifi, I will 
resubmit the patches turning on MSI for rtl8188ee and rtl8723ae.

Larry

> ---
>   drivers/net/wireless/rtlwifi/rtl8188ee/sw.c | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
> index 1b4101b..347af1e 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
> @@ -93,7 +93,6 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
>   	u8 tid;
>
>   	rtl8188ee_bt_reg_init(hw);
> -	rtlpci->msi_support = true;
>
>   	rtlpriv->dm.dm_initialgain_enable = 1;
>   	rtlpriv->dm.dm_flag = 0;
>
