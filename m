From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2 2/2] net: ixgbe: Use new
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Fri, 18 Aug 2017 08:39:23 +0800
Message-ID: <2a7fc27b-c2f4-a7a1-9318-3a93531e7670@huawei.com>
References: <1502940316-13384-1-git-send-email-dingtianhong@huawei.com>
 <1502940316-13384-3-git-send-email-dingtianhong@huawei.com>
 <87618083B2453E4A8714035B62D67992B4094F7A@FMSMSX105.amr.corp.intel.com>
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
In-Reply-To: <87618083B2453E4A8714035B62D67992B4094F7A@FMSMSX105.amr.corp.intel.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/8/17 22:17, Tantilov, Emil S wrote:

>> 	ret_val = ixgbe_start_hw_generic(hw);
>>
>> -#ifndef CONFIG_SPARC
>> -	/* Disable relaxed ordering */
>> -	for (i = 0; ((i < hw->mac.max_tx_queues) &&
>> -	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
>> -		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
>> -		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
>> -		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
>> -	}
>> +	if (!pcie_relaxed_ordering_enabled(adapter->pdev)) {
> 
> As Alex mentioned there is no need for this check in any form.
> 
> The HW defaults to Relaxed Ordering enabled unless it is disabled in 
> the PCIe Device Control Register. So the above logic is already done by HW.
> 
> All you have to do is strip the code disabling relaxed ordering.
> 

Hi Tantilov:

I misunderstood Alex's suggestion, But I still couldn't find the logic where
the HW disable the Relaxed Ordering when the PCIe Device Control Register
disable it, can you point it out?

Thanks
Ding

> Thanks,
> Emil
> 
> 
> .
> 

