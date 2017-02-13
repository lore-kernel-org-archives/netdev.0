From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 6/7] staging: r8712u: Fix Sparse warnings in
 rtl871x_ioctl_linux.c
Date: Mon, 13 Feb 2017 11:27:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0284E26@AcuExch.aculab.com>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
 <20170211033030.28827-7-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>
To: 'Larry Finger' <Larry.Finger@lwfinger.net>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:56194 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752200AbdBML1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 06:27:13 -0500
In-Reply-To: <20170211033030.28827-7-Larry.Finger@lwfinger.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger
> Sent: 11 February 2017 03:30
> Sparse reports the following:
>   CHECK   drivers/staging/rtl8712/rtl871x_ioctl_linux.c
> drivers/staging/rtl8712/rtl871x_ioctl_linux.c:1422:46: warning: restricted __le16 degrades to integer
> drivers/staging/rtl8712/rtl871x_ioctl_linux.c:1424:46: warning: restricted __le16 degrades to integer
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/staging/rtl8712/rtl871x_ioctl_linux.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
> b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
> index 0dc18d6..f4167f1 100644
> --- a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
> +++ b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
> @@ -1419,9 +1419,9 @@ static int r8711_wx_get_rate(struct net_device *dev,
>  			ht_cap = true;
>  			pht_capie = (struct ieee80211_ht_cap *)(p + 2);
>  			memcpy(&mcs_rate, pht_capie->supp_mcs_set, 2);
> -			bw_40MHz = (pht_capie->cap_info &
> +			bw_40MHz = (le16_to_cpu(pht_capie->cap_info) &
>  				    IEEE80211_HT_CAP_SUP_WIDTH) ? 1 : 0;
> -			short_GI = (pht_capie->cap_info &
> +			short_GI = (le16_to_cpu(pht_capie->cap_info) &
>  				    (IEEE80211_HT_CAP_SGI_20 |
>  				    IEEE80211_HT_CAP_SGI_40)) ? 1 : 0;

You've added a byteswap on le systems - so the title is wrong.
You need to sort out whether the byteswap is needed or not.

Also it is best to byteswap the constant.

	David
