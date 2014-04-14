From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc:On MCDI timeout, issue an FLR (and mark MCDI
 to fail-fast)
Date: Mon, 14 Apr 2014 13:53:55 -0400 (EDT)
Message-ID: <20140414.135355.1089731200551193712.davem@davemloft.net>
References: <534BF37F.6020604@solarflare.com>
	<534BF89E.5020603@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshah@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, rstonehouse@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbaDNRx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 13:53:57 -0400
In-Reply-To: <534BF89E.5020603@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Mon, 14 Apr 2014 16:02:54 +0100

> On 14/04/14 15:41, Shradha Shah wrote:
>> diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
>> index 75ef7ef..70c2473 100644
>> --- a/drivers/net/ethernet/sfc/enum.h
>> +++ b/drivers/net/ethernet/sfc/enum.h
>> @@ -165,7 +168,14 @@ enum reset_type {
>>  	RESET_TYPE_DMA_ERROR,
>>  	RESET_TYPE_TX_SKIP,
>>  	RESET_TYPE_MC_FAILURE,
>> -	RESET_TYPE_MC_BIST,
>> +	/* RESET_TYPE_MC_BIST and RESET_TYPE_MCDI_TIMEOUT are actually methods,
>> +	 * not just reasons, but they don't fit the scope hierarchy (they're
>> +	 * not well-ordered by inclusion)
>> +	 * We encode this by having their enum values be greater than
>> +	 * RESET_TYPE_MAX_METHOD.  This also prevents issuing them with
>> +	 * efx_ioctl_reset
>> +	 */
>> +	RESET_TYPE_MCDI_TIMEOUT,
>>  	RESET_TYPE_MAX,
>>  };
>>  
> Looks like I messed up this comment; this is only true of
> RESET_TYPE_MCDI_TIMEOUT, not RESET_TYPE_MC_BIST.
> So should be something like:
> 
>     /* RESET_TYPE_MCDI_TIMEOUT is actually a method, not just a reason, but
>     * it doesn't fit the scope hierarchy (not well-ordered by inclusion).
>     * We encode this by having its enum value be greater than
>     * RESET_TYPE_MAX_METHOD. This also prevents issuing it with
>     * efx_ioctl_reset.
>     */

Please resubmit with the comment fixed.
