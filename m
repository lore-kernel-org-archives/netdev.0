From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/6] myri10ge: limit the number of recoveries
Date: Tue, 08 May 2007 01:13:26 -0400
Message-ID: <464006F6.1040204@garzik.org>
References: <463F9E9E.8000808@ens-lyon.org> <463F9F4E.4060706@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54265 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967872AbXEHFN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:13:29 -0400
In-Reply-To: <463F9F4E.4060706@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Limit the number of recoveries from a NIC hw watchdog reset to
> 1 by default.  This is tweakable via the myri10ge_reset_recover
> tunable.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> Index: linux-git/drivers/net/myri10ge/myri10ge.c
> ===================================================================
> --- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:21:27.000000000 +0200
> +++ linux-git/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:21:45.000000000 +0200
> @@ -279,6 +279,11 @@
>  module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
>  MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
>  
> +static int myri10ge_reset_recover = 1;
> +module_param(myri10ge_reset_recover, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(myri10ge_reset_recover,
> +		 "Number of recoveries allowed from NIC hw reset\n");
> +
>  static int myri10ge_wcfifo = 0;
>  module_param(myri10ge_wcfifo, int, S_IRUGO);
>  MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
> @@ -2706,8 +2711,14 @@
>  		 * For now, just report it */
>  		reboot = myri10ge_read_reboot(mgp);
>  		printk(KERN_ERR
> -		       "myri10ge: %s: NIC rebooted (0x%x), resetting\n",
> -		       mgp->dev->name, reboot);
> +		       "myri10ge: %s: NIC rebooted (0x%x),%s resetting\n",
> +		       mgp->dev->name, reboot,
> +		       myri10ge_reset_recover ? " " : " not");
> +		if (myri10ge_reset_recover == 0)
> +			return;
> +
> +		myri10ge_reset_recover--;

NAK.  Tunables like this are generally (a) never touched by the vast 
majority of users, and (b) have useful values and purposes known only to 
Myri employees :)


