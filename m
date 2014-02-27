From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 2/4] stmmac: fix and better tune the default
 buffer sizes
Date: Thu, 27 Feb 2014 14:34:29 +0100
Message-ID: <530F3EE5.4080600@st.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com> <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CC945@AcuExch.aculab.com> <530F3784.5050304@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:46130 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752497AbaB0Ned (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 08:34:33 -0500
In-Reply-To: <530F3784.5050304@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/2014 2:03 PM, Giuseppe CAVALLARO wrote:
> On 2/27/2014 11:51 AM, David Laight wrote:
>> From: Giuseppe Cavallaro
>>> This patch is to fix and tune the default buffer sizes.
>>> It reduces the default bufsize used by the driver from
>>> 2048 to 1518 (taking into account the extra 4 bytes in case of VLAN).
>> ...
>>> -#define DMA_BUFFER_SIZE    BUF_SIZE_4KiB
>>> -static int buf_sz = DMA_BUFFER_SIZE;
>>
>> Does this means that the old default was 4k, not the 2k in the
>> patch description.
>
> no pbl, I'll fix it in the patch subject.
>
>>
>>> +#ifdef STMMAC_VLAN_TAG_USED
>>> +#define    DEFAULT_BUFSIZE    (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
>>> +#else
>>> +#define    DEFAULT_BUFSIZE    (ETH_FRAME_LEN + ETH_FCS_LEN)
>>> +#endif
>> ...
>>> +    if (unlikely((buf_sz < DEFAULT_BUFSIZE) || (buf_sz >
>>> BUF_SIZE_16KiB)))
>>> +        buf_sz = DEFAULT_BUFSIZE;
>>
>> It doesn't seem right to me for the minimum buffer size to
>> depend on a compile-time option for VLAN.
>
> Hmm, I can have a default suitable for all the cases.
> Indeed other drivers program buffers (dlink/sundance.c)
> and do other settings according Koption like CONFIG_VLAN_8021Q.
> It is not a problem to review and delete it.
>
>> Also (provided the hardware supports it) the rx buffers (are these
>> the ones being sized?) need to be aligned on a 4n+2 boundary in
>> order to avoid a realignment copy later on.
>
> This is true and indeed I had added the STMMAC_ALIGN to align all.
> In the past to get the right alignment for SH4.
>
>> So I'm not sure that some of these sizes are right and/or optimal.
>
> What do you suggest?
>
> Maybe, I can use a default for sure < 4KiB suitable to be used for VLAN
> frames (it will be aligned later).

I did some other check and indeed it is aligned to 2KiB so what do you
think if I use it instead of 4KiB? I do not remember why this was added
but it should be only set in case of we change the mtu and the driver
should take care about that.

if you agree, I can do further test on sh4 and arm and repost the patch

peppe



>
> Peppe
>
>>
>>     David
>>
>>
>>
>>
>>
>
>
>
