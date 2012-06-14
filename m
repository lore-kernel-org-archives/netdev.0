From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] be2net: Increase statistics structure size for
 skyhawk.
Date: Thu, 14 Jun 2012 19:50:02 +0100
Message-ID: <1339699802.2719.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339653105-7313-1-git-send-email-sarveshwar.bandi@emulex.com>
	 <57eadb3c-1687-40a3-b846-e1fcee3f5a58@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Vasundhara Volam <vasundhara.volam@emulex.com>
To: <sarveshwar.bandi@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47067 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756037Ab2FNSuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 14:50:06 -0400
In-Reply-To: <57eadb3c-1687-40a3-b846-e1fcee3f5a58@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-14 at 11:21 +0530, sarveshwar.bandi@emulex.com wrote:
> From: Vasundhara Volam <vasundhara.volam@emulex.com>
> 
> Increasing the hardware statistics structure to accomodate statistics for skyhawk.
> 
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
> index 2f6bb06..3c938f5 100644
> --- a/drivers/net/ethernet/emulex/benet/be_cmds.h
> +++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
> @@ -1566,7 +1566,7 @@ struct be_hw_stats_v1 {
>  	u32 rsvd0[BE_TXP_SW_SZ];
>  	struct be_erx_stats_v1 erx;
>  	struct be_pmem_stats pmem;
> -	u32 rsvd1[3];
> +	u32 rsvd1[18];
>  };
>  
>  struct be_cmd_req_get_stats_v1 {

Doesn't this merit a 'struct be_hw_stats_v2'?

Does this mean that the driver wasn't currently allocating enough memory
for the structure, and could that result in a buffer overrun?  If so
then this fix would need to go into 3.5 and 3.4.y as well.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
