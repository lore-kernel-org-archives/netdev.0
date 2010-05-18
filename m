From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Tue, 18 May 2010 18:28:57 +0200
Message-ID: <4BF2C049.1080901@ans.pl>
References: <C27F8246C663564A84BB7AB3439772421B78147539@IRVEXCHCCR01.corp.ad.broadcom.com> <4BF2B3BE.60209@ans.pl> <1274148718.7893.14.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:42282 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756755Ab0ERQ3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 12:29:01 -0400
In-Reply-To: <1274148718.7893.14.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-18 04:11, Michael Chan wrote:
>
> On Tue, 2010-05-18 at 08:35 -0700, Krzysztof Ol=C4=99dzki wrote:
>> On 2010-05-16 20:51, Michael Chan wrote:
>>> Krzysztof Oledzki wrote:
>>>
>>>>
>>>> Why the driver registers 5 interrupts instead of 4? How to
>>>> limit it to 4?
>>>>
>>>
>>> The first vector (eth0-0) handles link interrupt and other slow
>>> path events.  It also has an RX ring for non-IP packets that are
>>> not hashed by the RSS hash.  The majority of the rx packets should
>>> be hashed to the rx rings eth0-1 - eth0-4, so I would assign these
>>> vectors to different CPUs.
>>
>> Did some more test on a two 4 core CPUs (8 CPUs reported to the syst=
em)
>> and on a two 4 core CPUs with HT (16 CPUs reported to the system) an=
d in
>> both cases there are 8 instead of 9 vectors: eth0-0 .. eth0-7 (irqs =
61
>> .. 68). However, dmesg shows that 9 interrupts are allocated:
>>
>> bnx2 0000:01:00.0: irq 61 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 62 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 63 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 64 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 65 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 66 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 67 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 68 for MSI/MSI-X
>> bnx2 0000:01:00.0: irq 69 for MSI/MSI-X
>>
>> It such case, which ring will be used for slow path and non-IP packe=
ts
>> and why there is no additional queue like in a 4CPU case?
>>
>
> eth0-0 is always the one handling slow path, rx ring 0 (non-IP), and =
tx
> ring 0.  The last vector is not used by bnx2.  It is reserved for iSC=
SI
> which is handled by the cnic and bnx2i drivers.

Thanks again for the explanation.

Best regards,

			Krzysztof Ol=C4=99dzki
