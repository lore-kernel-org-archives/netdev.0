From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/9 RESENT] staging: r8188eu: Fix Sparse warnings in
 rtw_wlan_util
Date: Fri, 18 Oct 2013 23:05:02 +0100
Message-ID: <1382133902.3381.23.camel@bwh-desktop.uk.level5networks.com>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
	 <5261A928.3020007@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, netdev <netdev@vger.kernel.org>,
	<devel@driverdev.osuosl.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57221 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401Ab3JRWFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 18:05:07 -0400
In-Reply-To: <5261A928.3020007@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-18 at 16:33 -0500, Larry Finger wrote:
> Sparse shows the following warning:
> 
>    CHECK   drivers/staging/rtl8188eu/core/rtw_wlan_util.c
> drivers/staging/rtl8188eu/core/rtw_wlan_util.c:1635:25: warning: cast to 
> restricted __le16
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>   drivers/staging/rtl8188eu/core/rtw_wlan_util.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c 
> b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
> index 153ec61..30ba18c 100644
> --- a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
> +++ b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
> @@ -1632,7 +1632,7 @@ void process_addba_req(struct adapter *padapter, u8 
> *paddba_req, u8 *addr)
>   	psta = rtw_get_stainfo(pstapriv, addr);
>    	if (psta) {
> -		param = le16_to_cpu(preq->BA_para_set);
> +		param = preq->BA_para_set;

preq is pointing to a header which has fixed byte order on the wire, so
this field presumably really is little-endian and the struct definition
should be changed.

Comapre the various headers in drivers/staging/rtl8188eu/include/wifi.h
with struct ieee80211_mgmt in include/linux/ieee80211.h.

Ben.

>   		tid = (param>>2)&0x0f;
>   		preorder_ctrl = &psta->recvreorder_ctrl[tid];
>   		preorder_ctrl->indicate_seq = 0xffff;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
