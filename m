From: David Miller <davem@davemloft.net>
Subject: Re: [net 5/6] i40e: better return values
Date: Tue, 24 Sep 2013 10:12:31 -0400 (EDT)
Message-ID: <20130924.101231.1193830264265403478.davem@davemloft.net>
References: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1380015910-25927-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<1380022486.3575.74.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab3IXOMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 10:12:33 -0400
In-Reply-To: <1380022486.3575.74.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 24 Sep 2013 04:34:46 -0700

> On Tue, 2013-09-24 at 02:45 -0700, Jeff Kirsher wrote:
> 
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> []
>> @@ -3339,9 +3345,7 @@ static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
>>  	/* Traffic class index starts from zero so
>>  	 * increment to return the actual count
>>  	 */
>> -	num_tc++;
>> -
>> -	return num_tc;
>> +	return num_tc++;
> 
> Ick.  post_increment problem.
> 
> 	return ++num_tc;
> 
> There's nothing wrong with the original code
> unless this is a bugfix which should be documented
> better than "better return values".

Agreed, this style of coding is asking for a bug.

If you want to return "num_tc PLUS ONE" just say that:

	return num_tc + 1;

Why even use pre/post increment when the variable has no other
use than as a return value?
