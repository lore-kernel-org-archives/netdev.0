From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 2/4] stmmac: fix and better tune the default
 buffer sizes
Date: Thu, 27 Feb 2014 14:54:17 +0100
Message-ID: <530F4389.8060309@st.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com> <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CC945@AcuExch.aculab.com> <530F3784.5050304@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CCBB2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:51290 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751457AbaB0NyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 08:54:23 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CCBB2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

On 2/27/2014 2:31 PM, David Laight wrote:
> From: Giuseppe CAVALLARO
> ...
>>> Also (provided the hardware supports it) the rx buffers (are these
>>> the ones being sized?) need to be aligned on a 4n+2 boundary in
>>> order to avoid a realignment copy later on.
>>
>> This is true and indeed I had added the STMMAC_ALIGN to align all.
>> In the past to get the right alignment for SH4.
>>
>>> So I'm not sure that some of these sizes are right and/or optimal.
>>
>> What do you suggest?
>>
>> Maybe, I can use a default for sure < 4KiB suitable to be used for V=
LAN
>> frames (it will be aligned later).
>
> Dunno... It rather depends on what the length is actually used for!
> What you don=92t want to be doing is adding 2 (for the 4n+2) and then
> mallocing a 4096+2 byte buffer somewhere.

thanks for your support.

What do you mean for 4n+2?

we reserve 2 more when allocate the skb.
I had seen that, When I used 2KiB as default this pushes us to allocate
from the next larger slab on old SH4 platforms and sometime forcing me
to increment the min_free_kbytes also when we work with the std
Ethernet MTU :-(.

So for sure 4KiB is really big and not good especially for embedded
system where this driver lives.

>
> If the hardware does receive desegmentation, then you need to handle
> the 64k+ receives somewhere.
> If it doesn't then it doesn't matter if the hardware rx buffer size i=
s
> slightly too large (eg for VLAN or encapsulation full sized frames in=
 PPoE).
> 1536 bytes for the memory buffer avoids cache line sharing (read to
> offset 2).

IIUC, so what you finally suggest is to use a default value w/o Koption
and 1536bytes is suitable for vlan etc. This is ok and can be managed
w/o breaking the compatibility with old mac where the rx hw buffer
are limited in size and where jumbo is not supported.

> The last ethernet driver I wrote from scratch (maybe 20 years ago) se=
t
> the rx-ring to point to an array of 512 byte buffers (last was shorte=
r
> to avoid an extra page) and did an aligned copy into the message buff=
er.
> Only frames that crossed the ring end needed two copies.
> ISTR making the copy be cache line aligned so that a special cache li=
ne
> copy function could be used (I don't know if it ever was).
> For that system the cost of the aligned data copies was less that the
> complexity and cost of setting up the iommu.

ok

peppe
>
> 	David
>
>
>
>
>
