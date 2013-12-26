From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3.5 18/19] rtlwifi: slight optimization of addr compare
Date: Thu, 26 Dec 2013 16:47:50 +0400
Message-ID: <52BC2576.3090601@cogentembedded.com>
References: <52BC15EA.2020603@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33132 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948Ab3LZMru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 07:47:50 -0500
Received: by mail-lb0-f179.google.com with SMTP id w7so3603803lbi.24
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 04:47:49 -0800 (PST)
In-Reply-To: <52BC15EA.2020603@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-12-2013 15:41, Ding Tianhong wrote:

> Use possibly more efficient ether_addr_equal_unaligned
> instead of memcmp.

> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Chaoming Li <chaoming_li@realsil.com.cn>
> Cc: John W. Linville <linville@tuxdriver.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/wireless/rtlwifi/cam.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
> index 0e510f7..0276153 100644
> --- a/drivers/net/wireless/rtlwifi/cam.c
> +++ b/drivers/net/wireless/rtlwifi/cam.c
[...]
> @@ -335,7 +335,7 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
>   		addr = rtlpriv->sec.hwsec_cam_sta_addr[i];
>   		bitmap = (rtlpriv->sec.hwsec_cam_bitmap) >> i;
>   		if (((bitmap & BIT(0)) == BIT(0)) &&
> -		    (memcmp(addr, sta_addr, ETH_ALEN) == 0)) {
> +		    (ether_addr_equal_unaligned(addr, sta_addr))) {

    It's pointless to enclose function call in parens, again.

WBR, Sergei
