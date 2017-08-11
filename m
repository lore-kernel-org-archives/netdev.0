From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-next 03/12] e1000e: add check on e1e_wphy() return value
Date: Thu, 10 Aug 2017 21:47:36 -0500
Message-ID: <c36867bd-fcb1-40b6-4f6e-b3ad2e6360dc@embeddedor.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
 <20170809214746.28139-4-jeffrey.t.kirsher@intel.com>
 <1502387812.2219.44.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Joe Perches <joe@perches.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway30.websitewelcome.com ([192.185.194.16]:47834 "EHLO
        gateway30.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752011AbdHKDJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 23:09:59 -0400
Received: from cm13.websitewelcome.com (cm13.websitewelcome.com [100.42.49.6])
        by gateway30.websitewelcome.com (Postfix) with ESMTP id 974D767AEC
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 21:48:12 -0500 (CDT)
In-Reply-To: <1502387812.2219.44.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody,

I'm a little confused. Is this patch causing any trouble?

On 08/10/2017 12:56 PM, Joe Perches wrote:
> On Wed, 2017-08-09 at 14:47 -0700, Jeff Kirsher wrote:
>> From: Gustavo A R Silva <garsilva@embeddedor.com>
>>
>> Check return value from call to e1e_wphy(). This value is being
>> checked during previous calls to function e1e_wphy() and it seems
>> a check was missing here.
>
> The use of "it seems" here is less than compelling.
>

This is one of the first patches I sent. Maybe I should have added a 
note saying that this patch needed some testing, as I don't have the 
hardware to test it.

> Perhaps the write of 0x3140 to MII_BMCR takes too long for
> the return value used.
>
> Many other uses of e1e_wphy.*MII_BMCR are also not checked.
>
> For instance: the e100e/ethtool uses.
>
>> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> []
>> @@ -2437,6 +2437,8 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
>>  		if (hw->phy.revision < 2) {
>>  			e1000e_phy_sw_reset(hw);
>>  			ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
>> +			if (ret_val)
>> +				return ret_val;
>>  		}
>>  	}
>>

Thanks
-- 
Gustavo A. R. Silva
