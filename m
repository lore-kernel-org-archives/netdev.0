From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 1/1] orinoco: fix improper return value
Date: Thu, 8 Dec 2016 11:30:53 +0100
Message-ID: <ba836a62-d200-e1b0-f046-5604ef8b97dc@broadcom.com>
References: <1481157602-4011-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>, Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481157602-4011-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8-12-2016 1:40, Pan Bian wrote:
> Function orinoco_ioctl_commit() returns 0 (indicates success) when the
> call to orinoco_lock() fails. Thus, the return value is inconsistent with
> the execution status. It may be better to return "-EBUSY" when the call 
> to orinoco_lock() fails.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188671
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>
> ---
>  drivers/net/wireless/intersil/orinoco/wext.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/intersil/orinoco/wext.c b/drivers/net/wireless/intersil/orinoco/wext.c
> index 1d4dae4..fee57ea 100644
> --- a/drivers/net/wireless/intersil/orinoco/wext.c
> +++ b/drivers/net/wireless/intersil/orinoco/wext.c
> @@ -1314,7 +1314,7 @@ static int orinoco_ioctl_commit(struct net_device *dev,
>  		return 0;
>  
>  	if (orinoco_lock(priv, &flags) != 0)
> -		return err;
> +		return -EBUSY;

Actually, orinoco_lock will return either -EBUSY or 0 so maybe better to
just do:

	err = orinoco_lock(priv, &flags);
	if (err < 0)
		return err;

Regards,
Arend

>  	err = orinoco_commit(priv);
>  
> 
