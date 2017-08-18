From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2 2/2] net: ixgbe: Use new
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Fri, 18 Aug 2017 13:50:14 +0800
Message-ID: <ebad9bf1-ca6c-df9e-272b-8a5b79dd7dec@huawei.com>
References: <1502940316-13384-1-git-send-email-dingtianhong@huawei.com>
 <1502940316-13384-3-git-send-email-dingtianhong@huawei.com>
 <87618083B2453E4A8714035B62D67992B4094F7A@FMSMSX105.amr.corp.intel.com>
 <2a7fc27b-c2f4-a7a1-9318-3a93531e7670@huawei.com>
 <87618083B2453E4A8714035B62D67992B4095363@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <87618083B2453E4A8714035B62D67992B4095363@FMSMSX105.amr.corp.intel.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/8/18 13:04, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Ding Tianhong [mailto:dingtianhong@huawei.com]
>> Sent: Thursday, August 17, 2017 5:39 PM
>> To: Tantilov, Emil S <emil.s.tantilov@intel.com>; davem@davemloft.net;
>> Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; keescook@chromium.org;
>> linux-kernel@vger.kernel.org; sparclinux@vger.kernel.org; intel-wired-
>> lan@lists.osuosl.org; alexander.duyck@gmail.com; netdev@vger.kernel.org;
>> linuxarm@huawei.com
>> Subject: Re: [PATCH net v2 2/2] net: ixgbe: Use new
>> PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
>>
>>
>>
>> On 2017/8/17 22:17, Tantilov, Emil S wrote:
>>
>>>> 	ret_val = ixgbe_start_hw_generic(hw);
>>>>
>>>> -#ifndef CONFIG_SPARC
>>>> -	/* Disable relaxed ordering */
>>>> -	for (i = 0; ((i < hw->mac.max_tx_queues) &&
>>>> -	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
>>>> -		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
>>>> -		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
>>>> -		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
>>>> -	}
>>>> +	if (!pcie_relaxed_ordering_enabled(adapter->pdev)) {
>>>
>>> As Alex mentioned there is no need for this check in any form.
>>>
>>> The HW defaults to Relaxed Ordering enabled unless it is disabled in
>>> the PCIe Device Control Register. So the above logic is already done by
>> HW.
>>>
>>> All you have to do is strip the code disabling relaxed ordering.
>>>
>>
>> Hi Tantilov:
>>
>> I misunderstood Alex's suggestion, But I still couldn't find the logic
>> where
>> the HW disable the Relaxed Ordering when the PCIe Device Control Register
>> disable it, can you point it out?
> 
> If you look at the datasheet (82599) - the description of CTRL_EXT.RO_DIS (bit 17, 0b):
> 
> Relaxed Ordering Disable. When set to 1b, the device does not request any relaxed
> ordering transactions. When this bit is cleared and the Enable Relaxed Ordering bit in
> the Device Control register is set, the device requests relaxed ordering transactions per queues as configured in the DCA_RXCTRL[n] and DCA_TXCTRL[n] registers.
> 
> So if you remove the code that clears the bits in DCA_T/RXCTRL relaxed ordering should
> be enabled by HW when the bus allows it.
> 

Great, Thanks for your explanation.

> Thanks,
> Emil
> 
> 
> .
> 

