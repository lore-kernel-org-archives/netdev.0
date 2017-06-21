From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: intel: e1000e: add check on e1e_wphy() return
 value
Date: Wed, 21 Jun 2017 14:52:08 -0500
Message-ID: <20170621145208.Horde.eM1O3f5tAb_tIuGcYvFpDJZ@gator4166.hostgator.com>
References: <20170518172223.Horde.5kLLwxMJWThQKv0bAxTsk4D@gator4166.hostgator.com>
 <20170620212234.GA10957@embeddedgus>
 <CABawtvMeV9=_hhECX1hkVE5+fOytBdaf2pYtSU9xAfY_yPK-Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Ethan Zhao <ethan.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway20.websitewelcome.com ([192.185.53.25]:11011 "EHLO
        gateway20.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751038AbdFUTwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 15:52:12 -0400
Received: from cm10.websitewelcome.com (cm10.websitewelcome.com [100.42.49.4])
        by gateway20.websitewelcome.com (Postfix) with ESMTP id 3B162401003CF
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 14:52:09 -0500 (CDT)
In-Reply-To: <CABawtvMeV9=_hhECX1hkVE5+fOytBdaf2pYtSU9xAfY_yPK-Uw@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ethan,

Quoting Ethan Zhao <ethan.kernel@gmail.com>:

> Gustavo,
>
>    The return value of ret_val seems used to check if the access to PHY/NVM
> got its semaphore,  generally speaking, it is needed for every PHY
> access of this driver.
>
> Reviewed-by: Ethan Zhao <ethan.zhao@oracle.com>
>

Thank you very much for the clarification.

> On Wed, Jun 21, 2017 at 5:22 AM, Gustavo A. R. Silva
> <garsilva@embeddedor.com> wrote:
>> Check return value from call to e1e_wphy(). This value is being
>> checked during previous calls to function e1e_wphy() and it seems
>> a check was missing here.
>>
>> Addresses-Coverity-ID: 1226905
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c  
>> b/drivers/net/ethernet/intel/e1000e/ich8lan.c
>> index 68ea8b4..d6d4ed7 100644
>> --- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
>> +++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
>> @@ -2437,6 +2437,8 @@ static s32  
>> e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
>>                 if (hw->phy.revision < 2) {
>>                         e1000e_phy_sw_reset(hw);
>>                         ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
>> +                       if (ret_val)
>> +                               return ret_val;
>>                 }
>>         }
>>
>> --
>> 2.5.0
>>
