From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next v2 01/11] i40e: only warn once of PTP nonsupport in
 100Mbit speed
Date: Tue, 18 Nov 2014 10:24:01 -0800
Message-ID: <546B8EC1.3050407@gmail.com>
References: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1416302731-11327-2-git-send-email-jeffrey.t.kirsher@intel.com> <1416303220.2295.19.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Joe Perches <josephx.perches@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59481 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932109AbaKRSYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 13:24:11 -0500
Received: by mail-pd0-f174.google.com with SMTP id w10so5040677pde.19
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:24:11 -0800 (PST)
In-Reply-To: <1416303220.2295.19.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2014 01:33 AM, Jeff Kirsher wrote:
> On Tue, 2014-11-18 at 01:25 -0800, Jeff Kirsher wrote:
>> From: Shannon Nelson <shannon.nelson@intel.com>
>>
>> Only warn once that PTP is not supported when linked at 100Mbit.
>>
>> Yes, using a static this way means that this once-only message is not
>> port specific, but once only for the life of the driver, regardless of
>> the number of ports.  That should be plenty.
>>
>> Change-ID: Ie6476530056df408452e195ef06afd4f57caa4b2
>> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_ptp.c | 12 +++++++++---
>>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> Florian/Joe-
> 
> Since your patch to update the dev_level_once() function is going
> through Greg KH's tree, we will stick with this patch until it gets
> accepted and merged into Dave's tree.  Then we will provide a patch to
> update the driver.

Sounds absolutely reasonable to me.

> 
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
>> index 537b621..f9151037 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
>> @@ -382,11 +382,17 @@ void i40e_ptp_set_increment(struct i40e_pf *pf)
>>  		incval = I40E_PTP_1GB_INCVAL;
>>  		break;
>>  	case I40E_LINK_SPEED_100MB:
>> -		dev_warn(&pf->pdev->dev,
>> -			 "%s: 1588 functionality is not supported at 100 Mbps. Stopping the PHC.\n",
>> -			 __func__);
>> +	{
>> +		static int warn_once;
>> +
>> +		if (!warn_once) {
>> +			dev_warn(&pf->pdev->dev,
>> +				 "1588 functionality is not supported at 100 Mbps. Stopping the PHC.\n");
>> +			warn_once++;
>> +		}
>>  		incval = 0;
>>  		break;
>> +	}
>>  	case I40E_LINK_SPEED_40GB:
>>  	default:
>>  		incval = I40E_PTP_40GB_INCVAL;
> 
