From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1 of 2] netconsole: don't require struct console to
	send data
Date: Sun, 30 Nov 2008 11:21:34 -0600
Message-ID: <1228065694.3196.61.camel@calx>
References: <5b87df37a941e38bfd93.1227820261@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hollis Blanchard <hollisb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:39526 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbYK3RVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Nov 2008 12:21:51 -0500
In-Reply-To: <5b87df37a941e38bfd93.1227820261@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-27 at 15:11 -0600, Hollis Blanchard wrote:
> This will allow callers not on the console path to use write_msg().
> 
> Signed-off-by: Hollis Blanchard <hollisb@us.ibm.com>
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -67,7 +67,7 @@ __setup("netconsole=", option_setup);
>  /* Linked list of all configured targets */
>  static LIST_HEAD(target_list);
>  
> -/* This needs to be a spinlock because write_msg() cannot sleep */
> +/* This needs to be a spinlock because netconsole_write_msg() cannot sleep */
>  static DEFINE_SPINLOCK(target_list_lock);
>  
>  /**
> @@ -694,7 +694,7 @@ static struct notifier_block netconsole_
>  	.notifier_call  = netconsole_netdev_event,
>  };
>  
> -static void write_msg(struct console *con, const char *msg, unsigned int len)
> +static void netconsole_write_msg(const char *msg, unsigned int len)
>  {
>  	int frag, left;
>  	unsigned long flags;
> @@ -728,10 +728,15 @@ static void write_msg(struct console *co
>  	spin_unlock_irqrestore(&target_list_lock, flags);
>  }
>  
> +static void netconsole_console_write(struct console *con, const char *msg, unsigned int len)
> +{
> +	netconsole_write_msg(msg, len);
> +}
> +
>  static struct console netconsole = {
>  	.name	= "netcon",
>  	.flags	= CON_ENABLED,
> -	.write	= write_msg,
> +	.write	= netconsole_console_write,
>  };

This looks fine functionally, but the name change strikes me as
gratuitous.
 
>  static int __init init_netconsole(void)
-- 
Mathematics is the supreme nostalgia of our time.

