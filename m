From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [janitor] sis900: don't use yield()
Date: Tue, 27 Apr 2004 14:03:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408EA079.3060604@pobox.com>
References: <20040427103807.311caa42.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, ollie@sis.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20040427103807.311caa42.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> From: maximilian attems <janitor@sternwelten.at>
> 
> thanks to Felipe W Damasio hint rediffed.
> patch is on top of linux-2.6.6-rc2
> 
> yield() removes process from active array into expired array,
> better just yield the CPU for a bit.
> tested on my laptop with a sis900.
> 
> a++ maks
> 
> Index: linux-266-rc2-kj1/drivers/net/sis900.c
> ===================================================================
> --- linux-266-rc2-kj1.orig/drivers/net/sis900.c	2004-04-03 19:36:57.000000000 -0800
> +++ linux-266-rc2-kj1/drivers/net/sis900.c	2004-04-21 15:32:56.000000000 -0700
> @@ -600,7 +600,8 @@ static int __init sis900_mii_probe (stru
>  
>  	if(status & MII_STAT_LINK){
>  		while (poll_bit) {
> -			yield();
> +			set_current_state(TASK_UNINTERRUPTIBLE);
> +			schedule_timeout(HZ/100);


I would rather do schedule_timeout(1), as that's IMO closer to the 
intention...

	Jeff
