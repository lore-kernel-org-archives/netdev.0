From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 2/2] be2net: fix mbox polling for signal
 reception
Date: Thu, 12 May 2011 13:49:06 +0100
Message-ID: <1305204546.4065.395.camel@localhost>
References: <1305180663-12140-1-git-send-email-sathya.perla@emulex.com>
	 <f816628b-a4b6-4a53-867e-12e75bc7b4de@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56205 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab1ELMtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 08:49:10 -0400
In-Reply-To: <f816628b-a4b6-4a53-867e-12e75bc7b4de@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 11:41 +0530, Sathya Perla wrote:
> Sending mbox cmds require multiple steps of writing to the DB register and polling
> for an ack. Gettting interrupted in the middle by a signal breaks the mbox protocol.
> So, set the task to UNINTERRUPTIBLE for mbox polling.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/benet/be_cmds.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index bff41ed..55c8301 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -297,7 +297,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
>  			return -1;
>  		}
>  
> -		set_current_state(TASK_INTERRUPTIBLE);
> +		set_current_state(TASK_UNINTERRUPTIBLE);
>  		schedule_timeout(msecs_to_jiffies(1));

msleep(1) is a lot more readable.

Ben.

>  		msecs++;
>  	} while (true);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

