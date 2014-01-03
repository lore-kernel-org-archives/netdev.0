From: David Cohen <david.a.cohen@linux.intel.com>
Subject: Re: [PATCH net-next] r8152: fix the wrong return value
Date: Thu, 2 Jan 2014 21:38:17 -0800
Message-ID: <20140103053817.GA3403@psi-dev26.jf.intel.com>
References: <1388719316-5702-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1388719316-5702-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 03, 2014 at 11:21:56AM +0800, Hayes Wang wrote:
> The return value should be the boolean value, not the error code.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> Spotted-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
>  drivers/net/usb/r8152.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index e3d878c..13fabbb 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -2708,7 +2708,7 @@ static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
>  			ops->unload		= rtl8153_unload;
>  			break;
>  		default:
> -			ret = -EFAULT;
> +			ret = false;

How about fix the function's return type instead?
Returning bool for success/error in Linux kernel is not natural. You
gotta check rtl_ops_init() for success and !rtl_ops_init() for error.
And you are unable to return the error value.

Br, David

>  			break;
>  		}
>  		break;
> -- 
> 1.8.4.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
