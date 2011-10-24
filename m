From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH V2 2/4] MIPS: Add board support for Loongson1B
Date: Mon, 24 Oct 2011 17:35:17 +0200
Message-ID: <4EA585B5.5030405@st.com>
References: <1319192888-21465-1-git-send-email-keguang.zhang@gmail.com> <1319192888-21465-2-git-send-email-keguang.zhang@gmail.com> <CAD+V5YKBkW52_md9rBeVZ1RXq2FGEXt=Ergsw+z8txMreZdNsA@mail.gmail.com> <4EA5117C.3000402@st.com> <CAJhJPsVSzXXmBOwLaGNtOsxhVEyC0fAJtiBvEWzcKcSDC8NEcA@mail.gmail.com> <4EA557B2.4020504@st.com> <CAJhJPsXxUAuF9HdivLd66MQC45mz-iYAuF1SdGdU=-duxJJ5bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wu Zhangjin <wuzhangjin@gmail.com>, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	r0bertz@gentoo.org, netdev@vger.kernel.org
To: Kelvin Cheung <keguang.zhang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJhJPsXxUAuF9HdivLd66MQC45mz-iYAuF1SdGdU=-duxJJ5bQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/2011 4:05 PM, Kelvin Cheung wrote:
> 2011/10/24, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>> Hello Kelvin.
>>
>> On 10/24/2011 12:36 PM, Kelvin Cheung wrote:
>>
>> [snip]
>>
>>> According to datasheet of Loongson 1B, the buffer size in RX/TX
>>> descriptor is only 2KB. So the Loongson1B's GMAC could not handle
>>> jumbo frames. And the second buffer is useless in this case. Am I
>>> right? Is there a better way than ifdef CONFIG_MACH_LOONGSON1 to
>>> avoid duplicate code?
>>
>> Sorry for my misunderstanding.
>>
>> I think you have to use the normal descriptor and remove the enh_desc
>> from the platform w/o modifying the driver at all.
>>
>> The driver will be able to select/configure all automatically (also jumbo).
>>
>> Let me know.
> 
> That's the problem.
> The bitfield definition of Loongson1B is also different from normal descriptor.

The problem is not in the Loongson1B gmac.

The normal descriptor fields in the stmmac refer to an old synopsys
databook.
New chips have the same structure you have added; so we should fix this
in the driver w/o breaking the compatibility for old chips.
I kindly ask you to confirm if the currently normal descriptor structure
(w/o your changes) doesn't work on your platform.
Did you test it?

> Moreover, I want to enable the TX checksum offload function which is
> not supported in normal descriptor.
> Any suggestions?

It is supported but you have to pass from the platform: tx_coe = 1.

Peppe
> 
>> Note:
>> IIRC, there is a bit difference in case of normal descriptors for
>> Synopsys databook newer than the 1.91 (I used for testing this mode).
>> In any case, I remember that, on some platforms, the normal descriptors
>> have been used w/o problems also on these new chip generations.
>>
>> Peppe
>>
>>
> 
> 
