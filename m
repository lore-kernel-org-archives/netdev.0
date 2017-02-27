From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: fix timing for 82579 Gigabit
 Ethernet controller
Date: Mon, 27 Feb 2017 10:39:31 +0200
Message-ID: <3a432931-8b94-4808-78e0-bc459f510ab9@intel.com>
References: <1487270527-4549-1-git-send-email-berndfaust@gmail.com>
 <923e61cf-5f95-1662-2f4c-fc146359ab48@intel.com>
 <0a95307e-6683-b9fe-1957-be2b0a3c441e@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Bernd Faust <berndfaust@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0a95307e-6683-b9fe-1957-be2b0a3c441e@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/26/2017 11:08, Neftin, Sasha wrote:
> On 2/19/2017 14:55, Neftin, Sasha wrote:
>> On 2/16/2017 20:42, Bernd Faust wrote:
>>> After an upgrade to Linux kernel v4.x the hardware timestamps of the
>>> 82579 Gigabit Ethernet Controller are different than expected.
>>> The values that are being read are almost four times as big as before
>>> the kernel upgrade.
>>>
>>> The difference is that after the upgrade the driver sets the clock
>>> frequency to 25MHz, where before the upgrade it was set to 96MHz. Intel
>>> confirmed that the correct frequency for this network adapter is 96MHz.
>>>
>>> Signed-off-by: Bernd Faust <berndfaust@gmail.com>
>>> ---
>>>   drivers/net/ethernet/intel/e1000e/netdev.c | 6 ++++++
>>>   1 file changed, 6 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c 
>>> b/drivers/net/ethernet/intel/e1000e/netdev.c
>>> index 7017281..8b7113d 100644
>>> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
>>> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>>> @@ -3511,6 +3511,12 @@ s32 e1000e_get_base_timinca(struct 
>>> e1000_adapter *adapter, u32 *timinca)
>>>
>>>       switch (hw->mac.type) {
>>>       case e1000_pch2lan:
>>> +        /* Stable 96MHz frequency */
>>> +        incperiod = INCPERIOD_96MHz;
>>> +        incvalue = INCVALUE_96MHz;
>>> +        shift = INCVALUE_SHIFT_96MHz;
>>> +        adapter->cc.shift = shift + INCPERIOD_SHIFT_96MHz;
>>> +        break;
>>>       case e1000_pch_lpt:
>>>           if (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI) {
>>>               /* Stable 96MHz frequency */
>>> -- 
>>> 2.7.4
>>> _______________________________________________
>>> Intel-wired-lan mailing list
>>> Intel-wired-lan@lists.osuosl.org
>>> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
>>
>> Hello,
>>
>> e1000_pch2lan mac type corresponds to 82579LM and 82579V network 
>> adapters. System clock frequency indication (SYSCFI) for these 
>> devices supports both 25MHz and 96MHz frequency. By default 
>> TSYNCRXCTL.SYSCFI is set to 1 and that means 96MHz frequency is picked.
>>
>> It is better to keep the current implementation as it covers all 
>> options.
>>
>> Thanks,
>>
>> Sasha
>>
> Hello,
>
> During last couple of weeks I saw few  complaints from community on 
> same timing problem with 82579. I will double check clock definition 
> with HW architecture.
>
> Sasha
>
I've double checked - 82579 support 96MHz frequency only. So, let's 
accept this suggestion to upstream.

Ack.
