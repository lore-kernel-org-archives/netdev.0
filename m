From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [patch] p54: potential signedness issue in p54_parse_rssical()
Date: Sun, 2 Dec 2012 14:54:56 +0100
Message-ID: <201212021454.57147.chunkeey@googlemail.com>
References: <20121202103609.GA16078@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49757 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab2LBNzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 08:55:03 -0500
In-Reply-To: <20121202103609.GA16078@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 02 December 2012 11:36:09 Dan Carpenter wrote:
> "entries" is unsigned here, so it is never less than zero.  In theory,
> len could be less than offset so I have added a check for that.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Christian Lamparter <chunkeey@googlemail.com>

> diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
> index 1ef1bfe..d43e374 100644
> --- a/drivers/net/wireless/p54/eeprom.c
> +++ b/drivers/net/wireless/p54/eeprom.c
> @@ -541,8 +541,9 @@ static int p54_parse_rssical(struct ieee80211_hw *dev,
>  		entries = (len - offset) /
>  			sizeof(struct pda_rssi_cal_ext_entry);
>  
> -		if ((len - offset) % sizeof(struct pda_rssi_cal_ext_entry) ||
> -		    entries <= 0) {
> +		if (len < offset ||
> +		    (len - offset) % sizeof(struct pda_rssi_cal_ext_entry) ||
> +		    entries == 0) {
>  			wiphy_err(dev->wiphy, "invalid rssi database.\n");
>  			goto err_data;
>  		}
> 
