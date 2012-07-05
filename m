From: =?UTF-8?B?QWxleCBWaWxsYWPDrXMgTGFzc28=?= <a_villacis@palosanto.com>
Subject: Re: BISECTED: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNING on
 cable plug on Acer Aspire One, no network
Date: Wed, 04 Jul 2012 23:14:42 -0500
Message-ID: <4FF514B2.4050000@palosanto.com>
References: <4FF25A05.7050007@palosanto.com> <4FF25CC2.3050101@palosanto.com> <03be01cd58de$6c2a06d0$447e1470$%szyprowski@samsung.com> <4FF30129.5000702@palosanto.com> <000901cd59b2$f2a542e0$d7efc8a0$%szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Marek Szyprowski <m.szyprowski@samsung.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([201.234.196.171]:58726 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab2GEEOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 00:14:47 -0400
In-Reply-To: <000901cd59b2$f2a542e0$d7efc8a0$%szyprowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 04/07/12 02:02, Marek Szyprowski escribi=C3=B3:
> Hello,
>
> On Tuesday, July 03, 2012 4:27 PM Alex Villac=C3=AD=C2=ACs Lasso wrot=
e:
>
>> El 03/07/12 00:40, Marek Szyprowski escribi=C3=B3:
>>> Hi Alex,
>>>
>>> On Tuesday, July 03, 2012 4:45 AM Alex Villac=C3=ADs Lasso wrote:
>>>
>>>> -------- Mensaje original --------
>>>> Asunto:  BISECTED: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNING=
 on cable
>>>> plug on Acer Aspire One, no network Fecha:  Mon, 02 Jul 2012 21:33=
:41 -0500 De:
>>>>    Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> Para:  Fran=
cois Romieu
>>>> <romieu@fr.zoreil.com> CC:  netdev@vger.kernel.org
>>>> El 01/07/12 08:50, Alex Villac=C3=ADs Lasso escribi=C3=B3:
>>>>> El 11/06/12 16:38, Francois Romieu escribi=C3=B3:
>>>>>> Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> :
>>>>>> [...]
>>>>>>> $ grep XID dmesg-3.5.0-rc2.txt
>>>>>>> [   15.873858] r8169 0000:02:00.0: eth0: RTL8102e at 0xf7c0e000=
,
>>>>>>> 00:1e:68:e5:5d:b1, XID 04a00000 IRQ 44
>>>>>> The 8102e has not been touched by that many suspect patches but =
I do
>>>>>> not see where the problem is :o(
>>>>>>
>>>>>> Can you peel off the r8169 patches between 3.4.0 and 3.5-rc ?
>>>>>>
>>>>> Still present in 3.5-rc5. Bisection still in progress.
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>> My full bisection points to this commit:
>>>>
>>>> commit 0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6
>>>> Author: Marek Szyprowski <m.szyprowski@samsung.com>
>>>> Date:   Thu Dec 29 13:09:51 2011 +0100
>>>>
>>>>       X86: integrate CMA with DMA-mapping subsystem
>>>>
>>>>       This patch adds support for CMA to dma-mapping subsystem for=
 x86
>>>>       architecture that uses common pci-dma/pci-nommu implementati=
on. This
>>>>       allows to test CMA on KVM/QEMU and a lot of common x86 boxes=
=2E
>>>>
>>>>       Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
>>>>       Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
>>>>       CC: Michal Nazarewicz <mina86@mina86.com>
>>>>       Acked-by: Arnd Bergmann <arnd@arndb.de>
>>>>
>>>> Is this commit somehow messing with the network card DMA?
>>> This commit in fact touches DMA-mapping subsystem and introduces a =
bug,
>>> which has been finally fixed by commit c080e26edc3a2a3 merged to v3=
=2E5-rc3.
>>> After applying it the DMA-mapping subsystem should work exactly the=
 same was
>>> as in v3.4. Could you please check if it fixes this issue?
>>>
>>> Best regards
>> No. It still fails in 3.5-rc5, as mentioned before.
> Hmm. I was a bit confused, because both the subject and git bisect lo=
g pointed to v3.5-rc2,
> which had that bug. Maybe there is one some other issue present in v3=
=2E5-rc5 not related to
> my patches?
>
> Could you check with v3.5-rc5 if reverting patch c080e26edc3a2a3cdfa4=
c430c663ee1c3bbd8fae
> and 0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6 fixes the problems with =
rtl driver?
>
> Best regards
Reverting the two patches indeed fixes the bug on -rc5.
