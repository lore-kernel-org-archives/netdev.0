From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 15:07:26 -0500
Message-ID: <4F5E577E.7090808@gmail.com>
References: <1331561157-3820-1-git-send-email-sr@denx.de> <201203121606.26926.sr@denx.de> <4F5E169D.3070508@st.com> <201203121723.38411.sr@denx.de> <4F5E2858.4000708@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	Viresh Kumar <viresh.kumar@st.com>,
	devicetree-discuss@ozlabs.org, linux-arm-kernel@lists.infradead.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53191 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756584Ab2CLUHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 16:07:40 -0400
Received: by yenl12 with SMTP id l12so2987987yen.19
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 13:07:39 -0700 (PDT)
In-Reply-To: <4F5E2858.4000708@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2012 11:46 AM, Giuseppe CAVALLARO wrote:
> On 3/12/2012 5:23 PM, Stefan Roese wrote:
>> On Monday 12 March 2012 16:30:37 Giuseppe CAVALLARO wrote:
>>>>>> +Required properties:
>>>>>> +- compatible: Should be "stm,gmac"
>>>>>
>>>>> This is too generic. This should be 1 string per version of h/w.
>>>>
>>>> Viresh, Giuseppe, can you please suggest a proper string for the SPEAr600
>>>> STMMAC core, including version?
>>>>
>>>>> 'stm' should be 'st' according to vendor-prefixes.txt.
>>>
>>> I'm not familiar with devicetree; maybe we should have:
>>>
>>> "stmicro,mac100"
>>> "stmicro,gmac"
>>>
>>> or: st instead of stmicro if you prefer.
>>>
>>> in fact, stmmac is for mac100 and gmac devices.
>>
>> How about "st,spear600-gmac" for SPEAr600 then?
> 
> IIUC, as final result we should have something like this... that sounds
> quite good to me.
> 
> ST/ARM SPEAr
> "st,spear600-gmac"
> "st,spear1310-gmac"
>   ...
> 
> ST/SH
> 
> "st,stx7108-gmac"
> "st,stx7106-gmac"
> "st,stx7109-mac"    ->>> mac10/100
> ...
> 
> MIPS
> "st,Loongson1B"
> 

This seems fine to me.

Rob

>>  
>>>> Okay.
>>>>
>>>>>> +- reg: Address and length of the register set for the device
>>>>>> +- interrupt-parent: Should be the phandle for the interrupt controller
>>>>>> +  that services interrupts for this device
>>>>>> +- interrupts: Should contain the STMMAC interrupts
>>>>>> +- interrupt-names: Should contain the interrupt names "macirq"
>>>>>> +  "eth_wake_irq" if this interrupt is supported in the "interrupts"
>>>>>> +  property
>>>>>
>>>>> You should be able to tell this from the compatible string and number of
>>>>> interrupts.
>>>>
>>>> Yes. Currently the driver uses platform_get_irq_byname() to register the
>>>> irq's. That's why I added these properties. Is there something wrong with
>>>> using it this way?
>>>>
>>>>>> +- phy-mode: String, operation mode of the PHY interface.
>>>>>> +  Supported values are: "mii", "rmii", "gmii", "rgmii".
>>>>>> +- phy-addr: MDIO address of the PHY
>>>>>
>>>>> This is normally probed or the mdio bus is a sub-node of the MAC node.
>>>>> See arch/powerpc/boot/dts/mpc8377_mds.dts for an example.
>>>>
>>>> Okay, I'll rework this.
>>>>
>>>>>> +
>>>>>> +Optional properties:
>>>>>> +- stm,prog-burst-len: Specify the burst length
>>>>>> +- stm,has-gmac: Indicates that the controller supports 1000Mbps
>>>>>> +- stm,has-pmt: Indicates that the controller supports power management
>>>>>
>>>>> I think these should all be encoded by the compatible string.
>>>
>>> and should we have all the other flags e.g. tx_coe etc?
>>> (see stmmac.txt)
>>
>> As Rob suggested, some of these flags/parameters are implicitly defined by the 
>> compatible string. If this is not the case, then sure, those flags/parameters 
>> need to be provided via the device-tree as well. I just don't need "tx_coe" 
>> etc. for my platform (SPEAr600) as far as I know. I suggest to add support for 
>> them once they are really needed/used by other platforms.
> 
> Ok, but on SPEAr indeed some of these are not used at all.
> If you agree, we can go head with these and then we will add new ones
> next time. In the meantime, I will try to be more familiar with
> devicetree and provide further patches
> 
> peppe
> 
>>
>> Thanks,
>> Stefan
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
