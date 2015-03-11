From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/6] rtlwifi: Use common rtl_query_rxpwrpercentage
 function
Date: Wed, 11 Mar 2015 13:19:42 -0700
Message-ID: <1426105182.32696.57.camel@perches.com>
References: <1426104209-6913-1-git-send-email-plaes@plaes.org>
	 <1426104209-6913-2-git-send-email-plaes@plaes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: Priit Laes <plaes-q/aMd4JkU83YtjvyW6yDsg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426104209-6913-2-git-send-email-plaes-q/aMd4JkU83YtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-03-11 at 22:03 +0200, Priit Laes wrote:
> diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
[]
> @@ -26,14 +26,14 @@
>  #include "stats.h"
>  #include <linux/export.h>
>  
> +/* TODO: Figure out a better name */
>  u8 rtl_query_rxpwrpercentage(char antpower)
>  {
>  	if ((antpower <= -100) || (antpower >= 20))
>  		return 0;
>  	else if (antpower >= 0)
>  		return 100;
> -	else
> -		return 100 + antpower;
> +	return 100 + antpower;
> }

This is a superfluous change.

If it was changed because checkpatch emitted a warning,
there's a newer version of checkpatch that doesn't emit
a warning for this line.

If any change was to be made, I suggest reordering so
that the return values are written low to high like:

u8 rtl_query_rxpwrpercentage(char antpower)
{
	if ((antpower <= -100) || (antpower >= 20))
		return 0;
	else if (antpower < 0)
		return antpower + 100;
	else
		return 100;
}


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
