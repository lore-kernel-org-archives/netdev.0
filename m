From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 21:49:03 +0200
Message-ID: <4BF04C2F.1050407@ans.pl>
References: <C27F8246C663564A84BB7AB3439772421B78147539@IRVEXCHCCR01.corp.ad.broadcom.com> <4BF0465A.5030307@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:48241 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab0EPTtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 15:49:09 -0400
In-Reply-To: <4BF0465A.5030307@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-16 21:24, Krzysztof Ol=C4=99dzki wrote:
> On 2010-05-16 20:51, Michael Chan wrote:
>> Krzysztof Oledzki wrote:
>>
>>>
>>> Why the driver registers 5 interrupts instead of 4? How to
>>> limit it to 4?
>>>
>>
>> The first vector (eth0-0) handles link interrupt and other slow
>> path events.  It also has an RX ring for non-IP packets that are
>> not hashed by the RSS hash.  The majority of the rx packets should
>> be hashed to the rx rings eth0-1 - eth0-4, so I would assign these
>> vectors to different CPUs.
>
> Thank you for your prompt response.
>
> In my case the first vector must be handling something more:
>   - "ping -f 192.168.0.1" increases interrupts on both eth1-0 and eth=
1-4
>   - "ping -f 192.168.0.2" increases interrupts on both eth1-0 and eth=
1-3
>   - "ping -f 192.168.0.3" increases interrupts on both eth1-0 and eth=
1-1
>   - "ping -f 192.168.0.7" increases interrupts on both eth1-0 and eth=
1-2
>
>              CPU0       CPU1       CPU2       CPU3
>    67:    1563979          0          0          0   PCI-MSI-edge    =
  eth1-0
>    68:    1072869          0          0          0   PCI-MSI-edge    =
  eth1-1
>    69:     137905          0          0          0   PCI-MSI-edge    =
  eth1-2
>    70:     259246          0          0          0   PCI-MSI-edge    =
  eth1-3
>    71:     760252          0          0          0   PCI-MSI-edge    =
  eth1-4
>
> As you can see, eth1-1 + eth1-2 + eth1-3 + eth1-4 ~=3D eth1-0.
>
> So, it seems that TX or RX is always handled by the first vector.
> I'll try to find if it is TX or RX.
>
> BTW: I'm using .1Q vlans over bonding, does it change anything?

It looks like TX for locally generated packets is always performed on=20
eth1-0. I guess it should look differently for forwarded packets?

Best regards,

			Krzysztof Ol=C4=99dzki
