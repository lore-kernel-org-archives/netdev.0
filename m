From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 2/4] stmmac: fix and better tune the default
 buffer sizes
Date: Tue, 4 Mar 2014 08:20:49 +0100
Message-ID: <53157ED1.2010505@st.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com> <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CC945@AcuExch.aculab.com> <530F3784.5050304@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CCBB2@AcuExch.aculab.com> <530F4389.8060309@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:58841 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756137AbaCDHVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 02:21:03 -0500
In-Reply-To: <530F4389.8060309@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David

Sorry, can you tell me what is the final your opinion about
this patch?

I think that it not good to keep 4KiB as default and your main concern
was about the default buffer size that depended on VLAN ifconfig.

So I could adopt 1536bytes as default and remove ifdef.

I'd like to resubmit these first patches that add some relevant fixes
in the driver especially for EEE and chained mode that doesn't work
after latest reworks.

Best Regards
Peppe

On 2/27/2014 2:54 PM, Giuseppe CAVALLARO wrote:
> Hi David
>
> On 2/27/2014 2:31 PM, David Laight wrote:
>> From: Giuseppe CAVALLARO
>> ...
>>>> Also (provided the hardware supports it) the rx buffers (are these
>>>> the ones being sized?) need to be aligned on a 4n+2 boundary in
>>>> order to avoid a realignment copy later on.
>>>
>>> This is true and indeed I had added the STMMAC_ALIGN to align all.
>>> In the past to get the right alignment for SH4.
>>>
>>>> So I'm not sure that some of these sizes are right and/or optimal.
>>>
>>> What do you suggest?
>>>
>>> Maybe, I can use a default for sure < 4KiB suitable to be used for =
VLAN
>>> frames (it will be aligned later).
>>
>> Dunno... It rather depends on what the length is actually used for!
>> What you don=92t want to be doing is adding 2 (for the 4n+2) and the=
n
>> mallocing a 4096+2 byte buffer somewhere.
>
> thanks for your support.
>
> What do you mean for 4n+2?
>
> we reserve 2 more when allocate the skb.
> I had seen that, When I used 2KiB as default this pushes us to alloca=
te
> from the next larger slab on old SH4 platforms and sometime forcing m=
e
> to increment the min_free_kbytes also when we work with the std
> Ethernet MTU :-(.
>
> So for sure 4KiB is really big and not good especially for embedded
> system where this driver lives.
>
>>
>> If the hardware does receive desegmentation, then you need to handle
>> the 64k+ receives somewhere.
>> If it doesn't then it doesn't matter if the hardware rx buffer size =
is
>> slightly too large (eg for VLAN or encapsulation full sized frames i=
n
>> PPoE).
>> 1536 bytes for the memory buffer avoids cache line sharing (read to
>> offset 2).
>
> IIUC, so what you finally suggest is to use a default value w/o Kopti=
on
> and 1536bytes is suitable for vlan etc. This is ok and can be managed
> w/o breaking the compatibility with old mac where the rx hw buffer
> are limited in size and where jumbo is not supported.
>
>> The last ethernet driver I wrote from scratch (maybe 20 years ago) s=
et
>> the rx-ring to point to an array of 512 byte buffers (last was short=
er
>> to avoid an extra page) and did an aligned copy into the message buf=
fer.
>> Only frames that crossed the ring end needed two copies.
>> ISTR making the copy be cache line aligned so that a special cache l=
ine
>> copy function could be used (I don't know if it ever was).
>> For that system the cost of the aligned data copies was less that th=
e
>> complexity and cost of setting up the iommu.
>
> ok
>
> peppe
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
