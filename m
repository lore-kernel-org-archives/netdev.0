From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2009-08-11
Date: Wed, 12 Aug 2009 14:24:03 -0400
Message-ID: <20090812182403.GF2657@tuxdriver.com>
References: <20090811183605.GG2634@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40422 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751AbZHLSaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 14:30:08 -0400
Content-Disposition: inline
In-Reply-To: <20090811183605.GG2634@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

When you pull this, could you also revert 57921c31 ("libertas: Read
buffer overflow").  It has been shown to create a new problem.  There
is work towards a solution to that one, but it isn't a simple clean-up.

If you would prefer, I can include the revert with another pull
request or even regenerate this one.  Just let me know if that is
what you prefer.

Thanks,

John

On Tue, Aug 11, 2009 at 02:36:06PM -0400, John W. Linville wrote:
> Dave,
> 
> Here are a couple more minor fixes intended for 2.6.31.  Hopefully we
> are winding-down!
> 
> Please let me know if there are problems!
> 
> John
> 
> ---
> 
> Individual patches are available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/
> 
> ---
> 
> The following changes since commit 973507cb8610d4c84f090d5f1f0ca54fa0559d27:
>   roel kluin (1):
>         mlx4_en: Fix read buffer overflow in mlx4_en_complete_rx_desc()
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master
> 
> Christian Lamparter (1):
>       ar9170usb: fix spurious firmware related message
> 
> Dan Carpenter (1):
>       ar9170: fix read & write outside array bounds
> 
>  drivers/net/wireless/ath/ar9170/main.c |    5 +++--
>  drivers/net/wireless/ath/ar9170/usb.c  |    6 +++++-
>  2 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ar9170/main.c b/drivers/net/wireless/ath/ar9170/main.c
> index 9d38cf6..88c3d85 100644
> --- a/drivers/net/wireless/ath/ar9170/main.c
> +++ b/drivers/net/wireless/ath/ar9170/main.c
> @@ -1967,13 +1967,14 @@ static int ar9170_conf_tx(struct ieee80211_hw *hw, u16 queue,
>  	int ret;
>  
>  	mutex_lock(&ar->mutex);
> -	if ((param) && !(queue > __AR9170_NUM_TXQ)) {
> +	if (queue < __AR9170_NUM_TXQ) {
>  		memcpy(&ar->edcf[ar9170_qos_hwmap[queue]],
>  		       param, sizeof(*param));
>  
>  		ret = ar9170_set_qos(ar);
> -	} else
> +	} else {
>  		ret = -EINVAL;
> +	}
>  
>  	mutex_unlock(&ar->mutex);
>  	return ret;
> diff --git a/drivers/net/wireless/ath/ar9170/usb.c b/drivers/net/wireless/ath/ar9170/usb.c
> index 754b1f8..007eb85 100644
> --- a/drivers/net/wireless/ath/ar9170/usb.c
> +++ b/drivers/net/wireless/ath/ar9170/usb.c
> @@ -598,11 +598,15 @@ static int ar9170_usb_request_firmware(struct ar9170_usb *aru)
>  
>  	err = request_firmware(&aru->init_values, "ar9170-1.fw",
>  			       &aru->udev->dev);
> +	if (err) {
> +		dev_err(&aru->udev->dev, "file with init values not found.\n");
> +		return err;
> +	}
>  
>  	err = request_firmware(&aru->firmware, "ar9170-2.fw", &aru->udev->dev);
>  	if (err) {
>  		release_firmware(aru->init_values);
> -		dev_err(&aru->udev->dev, "file with init values not found.\n");
> +		dev_err(&aru->udev->dev, "firmware file not found.\n");
>  		return err;
>  	}
>  
> -- 
> John W. Linville		Someday the world will need a hero, and you
> linville@tuxdriver.com			might be all we have.  Be ready.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
