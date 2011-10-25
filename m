From: Kelvin Cheung <keguang.zhang@gmail.com>
Subject: Re: [PATCH V2 2/4] MIPS: Add board support for Loongson1B
Date: Tue, 25 Oct 2011 17:21:13 +0800
Message-ID: <CAJhJPsUE1G5hRU7nSxjUU4aG+1BKDQD_kov1Xzg5k2_prjm_4w@mail.gmail.com>
References: <1319192888-21465-1-git-send-email-keguang.zhang@gmail.com>
	<1319192888-21465-2-git-send-email-keguang.zhang@gmail.com>
	<CAD+V5YKBkW52_md9rBeVZ1RXq2FGEXt=Ergsw+z8txMreZdNsA@mail.gmail.com>
	<4EA5117C.3000402@st.com>
	<CAJhJPsVSzXXmBOwLaGNtOsxhVEyC0fAJtiBvEWzcKcSDC8NEcA@mail.gmail.com>
	<4EA557B2.4020504@st.com>
	<CAJhJPsXxUAuF9HdivLd66MQC45mz-iYAuF1SdGdU=-duxJJ5bQ@mail.gmail.com>
	<4EA585B5.5030405@st.com>
	<CAJhJPsVu7hahhmUvPQ=s=AqvXGhU-05x=GqQ29Mo6PZ8cTtefA@mail.gmail.com>
	<4EA660C0.1020901@st.com>
	<4EA6716A.80307@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Wu Zhangjin <wuzhangjin@gmail.com>, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	r0bertz@gentoo.org, netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EA6716A.80307@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/10/25, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
> On 10/25/2011 9:09 AM, Giuseppe CAVALLARO wrote:
>> On 10/25/2011 4:12 AM, Kelvin Cheung wrote:
>>> 2011/10/24, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>>>> On 10/24/2011 4:05 PM, Kelvin Cheung wrote:
>>>>> 2011/10/24, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>>>>>> Hello Kelvin.
>>>>>>
>>>>>> On 10/24/2011 12:36 PM, Kelvin Cheung wrote:
>>>>>>
>>>>>> [snip]
>>>>>>
>>>>>>> According to datasheet of Loongson 1B, the buffer size in RX/TX
>>>>>>> descriptor is only 2KB. So the Loongson1B's GMAC could not handle
>>>>>>> jumbo frames. And the second buffer is useless in this case. Am I
>>>>>>> right? Is there a better way than ifdef CONFIG_MACH_LOONGSON1 to
>>>>>>> avoid duplicate code?
>>>>>>
>>>>>> Sorry for my misunderstanding.
>>>>>>
>>>>>> I think you have to use the normal descriptor and remove the enh_desc
>>>>>> from the platform w/o modifying the driver at all.
>>>>>>
>>>>>> The driver will be able to select/configure all automatically (also
>>>>>> jumbo).
>>>>>>
>>>>>> Let me know.
>>>>>
>>>>> That's the problem.
>>>>> The bitfield definition of Loongson1B is also different from normal
>>>>> descriptor.
>>>>
>>>> The problem is not in the Loongson1B gmac.
>>>
>>> I found that the bit checksum_insertion is not existed in normal
>>> descriptor.
>>>
>>>> The normal descriptor fields in the stmmac refer to an old synopsys
>>>> databook.
>>>
>>> Could you send me the new databook of Synopsys GMAC?
>>>
>>>> New chips have the same structure you have added; so we should fix this
>>>> in the driver w/o breaking the compatibility for old chips.
>>>
>>> Agree.
>>>
>>>> I kindly ask you to confirm if the currently normal descriptor structure
>>>> (w/o your changes) doesn't work on your platform.
>>>> Did you test it?
>>>
>>> Well, the normal descriptor works on my platform except TX checksum
>>> offload.
>>
>> ok! I suspected that.
>>
>>
>>>>> Moreover, I want to enable the TX checksum offload function which is
>>>>> not supported in normal descriptor.
>>>>> Any suggestions?
>>>>
>>>> It is supported but you have to pass from the platform: tx_coe = 1.
>>>
>>> I noticed that the flag csum_insertion is passed to
>>> ndesc_prepare_tx_desc() in stmmac_xmit(). But ndesc_prepare_tx_desc()
>>> just ignores it.
>>> In other words, the TX checksum offload function is disabled in normal
>>> descriptor currently.
>>>
>>> Should we fix this problem for normal descriptor?
>>
>> Yes, we should. If you agree, I'll update the normal descriptor
>> structure to yours. This is the normal descriptor used in newer GMAC.
>> Tx csum will be done for normal descriptors in case of these GMAC
>> devices and not for old MAC10/100. For the MAC10/100 some bits for
>> normal descriptors are reserved and won't be used at all.
>>
>> I'll also verify that the patch doesn't break the back-compatibility
>> with old MAC10/100. I have the HW where doing the tests.
>>
>> After that, I'll prepare the patch for net-next and for your kernel.
>
> Hello Kelvin
>
> attached the patch tested on my development kernel.
> It runs fine on old and new mac devices.
>
> Can you try it on your side? Hmm, it is likely it won't apply fine on
> your tree but you know the changes ;-).

Sure.

> If ok, I'll rework it for net-next and send it to the mailing list.
>
> Thanks
> Peppe
>
>>
>>>
>>>> Peppe
>>>>>
>>>>>> Note:
>>>>>> IIRC, there is a bit difference in case of normal descriptors for
>>>>>> Synopsys databook newer than the 1.91 (I used for testing this mode).
>>>>>> In any case, I remember that, on some platforms, the normal
>>>>>> descriptors
>>>>>> have been used w/o problems also on these new chip generations.
>>>>>>
>>>>>> Peppe
>>>>>>
>>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>


-- 
Best Regards!
Kelvin
