From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] slcan: remove unused 'leased', 'line' and 'pid' fields
 from the 'slcan' structure
Date: Tue, 19 Jul 2011 17:27:35 +0200
Message-ID: <4E25A267.4030005@hartkopp.net>
References: <CAKh5naa=x13=wUE+MLAYv0XQ4OhuY5G47ZDmFz0vbkibNtoz-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:32545 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab1GSP1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 11:27:37 -0400
In-Reply-To: <CAKh5naa=x13=wUE+MLAYv0XQ4OhuY5G47ZDmFz0vbkibNtoz-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.07.2011 09:58, Matvejchikov Ilya wrote:
> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
> ---

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Thanks Ilya!

Your cleanup is obviously fixing some fallout from this patch

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=5342b77c4123ba39f911d92a813295fb3bb21f69

which emerged in 2.6.32 for slip.c .

Best regards,
Oliver


>  drivers/net/can/slcan.c |   10 +---------
>  1 files changed, 1 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
> index 1b49df6..805ee29 100644
> --- a/drivers/net/can/slcan.c
> +++ b/drivers/net/can/slcan.c
> @@ -95,10 +95,6 @@ struct slcan {
>  	unsigned long		flags;		/* Flag values/ mode etc     */
>  #define SLF_INUSE		0		/* Channel in use            */
>  #define SLF_ERROR		1               /* Parity, etc. error        */
> -
> -	unsigned char		leased;
> -	dev_t			line;
> -	pid_t			pid;
>  };
> 
>  static struct net_device **slcan_devs;
> @@ -462,7 +458,7 @@ static void slc_sync(void)
>  			break;
> 
>  		sl = netdev_priv(dev);
> -		if (sl->tty || sl->leased)
> +		if (sl->tty)
>  			continue;
>  		if (dev->flags & IFF_UP)
>  			dev_close(dev);
> @@ -565,8 +561,6 @@ static int slcan_open(struct tty_struct *tty)
> 
>  	sl->tty = tty;
>  	tty->disc_data = sl;
> -	sl->line = tty_devnum(tty);
> -	sl->pid = current->pid;
> 
>  	if (!test_bit(SLF_INUSE, &sl->flags)) {
>  		/* Perform the low-level SLCAN initialization. */
> @@ -617,8 +611,6 @@ static void slcan_close(struct tty_struct *tty)
> 
>  	tty->disc_data = NULL;
>  	sl->tty = NULL;
> -	if (!sl->leased)
> -		sl->line = 0;
> 
>  	/* Flush network side */
>  	unregister_netdev(sl->dev);

