From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet
	transmission when polling with KGDB
Date: Fri, 29 May 2009 07:20:18 -0400
Message-ID: <8bd0f97a0905290420g454c3affr21b6f05e5971d93@mail.gmail.com>
References: <1243404615-25879-3-git-send-email-vapier@gentoo.org>
	 <20090529.020405.170805407.davem@davemloft.net>
	 <8bd0f97a0905290346v542e83cdg321241f0b4d95d9e@mail.gmail.com>
	 <20090529.035224.124353374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com, cooloney@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:4922 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755096AbZE2LUR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:20:17 -0400
Received: by yw-out-2324.google.com with SMTP id 5so3400332ywb.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 04:20:18 -0700 (PDT)
In-Reply-To: <20090529.035224.124353374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 06:52, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> On Fri, May 29, 2009 at 05:04, David Miller wrote:
>>> From: Mike Frysinger <vapier@gentoo.org>
>>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>>>
>>>> Make sure data is really written into the registers before enablin=
g DMA.
>>>> Otherwise, the EMAC DMA controller may transfer out a malformed pa=
cket.
>>>> This patch may also fix netperf bugs or scp bugs.
>>>>
>>>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>>>> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
>>>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>>>
>>> Instead of using this incredibly non-portable blackfin specific SSY=
NC
>>> thing
>>
>> that doesnt make sense -- this is a completely non-portable Blackfin
>> specific driver. =C2=A0everything in it uses Blackfin macros to acce=
ss
>> Blackfin MMRs because this is a device that only exists on Blackfin
>> chips.
>
> There is never an excuse to not write portable code when you can.
>
> Some day we may have dummy do-nothing bus drivers for every platform
> bus or subsystem, so that we can compile any driver on any platform.
>
> Do you want to make that kind of build validation of you code harder?

if the portable version is unnecessarily ugly to implement, then yes,
especially this driver which has a lot more issues than an SSYNC macro

>>> why not read back a register from the device to ensure the
>>> register writes hit the chip just like other drivers do?
>>
>> because that isnt how the Blackfin hardware works in general, and
>> certainly not how the DMA hardware works.
>
> Have you tried reading the register back? =C2=A0Does it work?

that isnt how the DMA is being used here.  there is no register to
read back because the DMA controller is doing the reading indirectly.
but along those lines, it's not entirely clear which DMA registers
this SSYNC is supposed to be protecting because all of the updates are
happening on the descriptors in external memory, not the DMA registers
themselves.  i'll have Sonic clarify.
-mike
