From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] be2net: hash key for rss-config cmd not set
Date: Mon, 23 May 2011 08:48:38 -0700
Message-ID: <1306165718.3456.53.camel@localhost>
References: <249a7eac-6aa7-481d-b7b0-a2a3b144963f@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1999 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407Ab1EWPsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 11:48:40 -0400
In-Reply-To: <249a7eac-6aa7-481d-b7b0-a2a3b144963f@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-23 at 17:55 +0530, Sathya Perla wrote:
> Need a random hash key to effectively hash incoming connections into
> multiple RX rings.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/benet/be_cmds.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index 2463b1c..81654ae 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -1703,7 +1703,8 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
>  {
>  	struct be_mcc_wrb *wrb;
>  	struct be_cmd_req_rss_config *req;
> -	u32 myhash[10];

/* Chosen by a fair dice roll */ ?
> +	u32 myhash[10] = {0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF,
> +			0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF};
>  	int status;
>  
>  	if (mutex_lock_interruptible(&adapter->mbox_lock))

This is of course less random than the stack garbage you were presumably
using before.  Though I don't know to what extent random hash keys are
really a good idea.

I have heard the suggestion that Toeplitz hash keys should in fact be
randomised per-system, so that flows will be hashed to the same queue
numbers on each interface if their hash indirection tales are also the
same.  This would presumably be good for bonding with multiple active
links, forwarding, etc., especially when multiple drivers (which
currently have different behaviour) are involved.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

