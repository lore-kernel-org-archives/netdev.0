From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] RFKILL: fix input layer initialisation
Date: Thu, 19 Jun 2008 20:49:54 +0200
Message-ID: <200806192049.54798.IvDoorn@gmail.com>
References: <20080619112841.GA12051@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dmitry Baryshkov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:52604 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbYFSSdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 14:33:00 -0400
Received: by py-out-1112.google.com with SMTP id p76so376414pyb.10
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 11:33:00 -0700 (PDT)
In-Reply-To: <20080619112841.GA12051@doriath.ww600.siemens.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 June 2008, Dmitry Baryshkov wrote:
> Initialise correctly last fields, so tasks can be actually executed
> 
> Also move rfkill-input initialisation to subsys level so that it's
> available before generic drivers probing occurs.
> 
> Signed-off-by: Dmitry Baryshkov <dbaryshkov@gmail.com>
> ---
>  net/rfkill/rfkill-input.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
> index e4b051d..e4540fc 100644
> --- a/net/rfkill/rfkill-input.c
> +++ b/net/rfkill/rfkill-input.c
> @@ -181,6 +181,11 @@ static struct input_handler rfkill_handler = {
>  
>  static int __init rfkill_handler_init(void)
>  {
> +	unsigned long last_run = jiffies - msecs_to_jiffies(500);
> +	rfkill_wlan.last = last_run;
> +	rfkill_bt.last = last_run;
> +	rfkill_uwb.last = last_run;
> +	rfkill_wimax.last = last_run;

I'm not really fan of this approach
Can't this not be done someway in the DEFINE_RFKILL_TASK macro
where the entire structure is initialized?
That way it will automatically be set for all new rfkill task structures later.

>  	return input_register_handler(&rfkill_handler);
>  }
>  
> @@ -190,5 +195,5 @@ static void __exit rfkill_handler_exit(void)
>  	flush_scheduled_work();
>  }
>  
> -module_init(rfkill_handler_init);
> +subsys_initcall(rfkill_handler_init);
>  module_exit(rfkill_handler_exit);

This sounds good.

Ivo
