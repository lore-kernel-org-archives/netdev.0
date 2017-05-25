From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [PATCH] i40e: Fix incorrect pf->flags
Date: Thu, 25 May 2017 09:00:24 -0700
Message-ID: <4b4638a9-a995-de0a-cdcd-97c891e1b6b3@oracle.com>
References: <1495242112-14835-1-git-send-email-tushar.n.dave@oracle.com>
 <1495703624.49259.39.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48226 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942555AbdEYQBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:01:16 -0400
In-Reply-To: <1495703624.49259.39.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/25/2017 02:13 AM, Jeff Kirsher wrote:
> On Fri, 2017-05-19 at 18:01 -0700, Tushar Dave wrote:
>> Fix bug introduced by 'commit 47994c119a36e ("i40e: remove
>> hw_disabled_flags in favor of using separate flag bits")' that
>> mistakenly wipes out pf->flags.
>>
>> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> :-(
> Not even close to applying, I even tried to apply by hand but the patch
> was not near the same as my branch in my tree.  I will forgive this
> second instance of a patch generated on different tree/branch, but I
> really must insist that you use my tree & branch if you need/want to
> make changes to Intel wired LAN driver changes.
Apology Jeff. I used Dave's net tree.
Now onwards, I will use your 'net-queue:dev_queue' for bug fixes and
'next-queue:dev_queue' for developmental changes to Intel Ethernet drivers.

Being this patch a bug fix, I will send v2 based off your git tree
'net-queue' on branch 'dev_queue'. Hope that is okay?

Thanks.

-Tushar
>
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index d5c9c9e..6b98d34 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -8821,9 +8821,9 @@ static int i40e_sw_init(struct i40e_pf *pf)
>>  		    (pf->hw.aq.api_min_ver > 4))) {
>>  		/* Supported in FW API version higher than 1.4 */
>>  		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
>> -		pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>> +		pf->flags |= I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>>  	} else {
>> -		pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>> +		pf->flags |= I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>>  	}
>>
>>  	pf->eeprom_version = 0xDEAD;
