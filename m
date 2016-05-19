From: Petko Manolov <petkan@mip-labs.com>
Subject: Re: [PATCH 1/1] net: pegasus: simplify logical constraint
Date: Thu, 19 May 2016 08:57:55 +0300
Message-ID: <20160519055755.GE21813@p310>
References: <1463555740.22748.0.camel@suse.com>
 <1463596851-3581-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petko Manolov <petkan@nucleusys.com>,
	Oliver Neukum <oneukum@suse.com>,
	Guenter Roeck <linux@roeck-us.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463596851-3581-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-05-18 20:40:51, Heinrich Schuchardt wrote:
> If !count is true, count < 4 is also true.

Yep, you're right.  However, gcc optimizes away the first condition.  What you 
really got me to think about is whether 4 is the right number.  I guess i shall 
refer to the HW documentation.


		Petko


> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/usb/pegasus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 36cd7f0..9bbe0161 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -473,7 +473,7 @@ static void read_bulk_callback(struct urb *urb)
>  		goto goon;
>  	}
>  
> -	if (!count || count < 4)
> +	if (count < 4)
>  		goto goon;
>  
>  	rx_status = buf[count - 2];
> -- 
> 2.1.4
> 
> 
