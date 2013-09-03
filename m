From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: BQL support in gianfar causes network hiccup
Date: Tue, 3 Sep 2013 10:06:08 +0300
Message-ID: <52258A60.8040305@freescale.com>
References: <522490CB.60008@appeartv.com> <52249859.2040605@freescale.com> <5224A2A8.6000306@appeartv.com> <5224B026.8090803@freescale.com> <5224C1EB.3030307@appeartv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Per_Dal=E9n?= <per.dalen@appeartv.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:14793
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759439Ab3ICHGR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 03:06:17 -0400
In-Reply-To: <5224C1EB.3030307@appeartv.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/2/2013 7:50 PM, Per Dal=E9n wrote:
> On 09/02/2013 05:35 PM, Claudiu Manoil wrote:
>> On 9/2/2013 5:37 PM, Per Dal=E9n wrote:
>>>> The proposed fix is currently under review:
>>>> http://patchwork.ozlabs.org/patch/271242/
>>>> "gianfar: Fix reported number of sent bytes to BQL"
>>>>
>>>> Does this one work for you? You might need to pull
>>>> one recent gianfar clean-up patch from net-next in order
>>>> to apply this one without incidents.
>>>>
>>>
>>> No, still the same error:
>>>
>>> NETDEV WATCHDOG: eth0 (fsl-gianfar): transmit queue 0 timed out
>>> ------------[ cut here ]------------
>>> WARNING: at net/sched/sch_generic.c:256
>>> Modules linked in:
>>> NIP: c039ce0c LR: c039ce0c CTR: c02ef578
>>> ...
>>> 4e800421 80fe0244 4bffff40 7fc3f378 4bfea9d1 7fc4f378 7c651b78 3c60=
c055
>>> 7fe6fb78 38635304 4cc63182 480fcddd <0fe00000> 39200001 993c0a3c
>>> 4bffffb4
>>> ---[ end trace 5f5e1e3c30024010 ]---
>>>
>>>
>>
>> Tried to reproduce the issue with a recent net-next kernel (Linux
>> p2020rdb 3.11.0-rc6) + BQL fix patch (http://patchwork.ozlabs.org/pa=
tc
>> /271242/), but the iperf test finished without incidents (see log
>> below).
>> Will try if the problem is apparent without the fix patch, on the sa=
me
>> net-next kernel (3.11.0-rc6).
>>
>
> I was able to reproduce it on our card and the P2020RDB using 3.11.0-=
rc7
> + David Miller's -next networking tree and your patch
> (http://patchwork.ozlabs.org/patch/271242/).
>
> root@p2020rdb:~# iperf -s

Ok, I see, iperf -s on P2020. This way I was able to get the tx timeout
too.  With iperf -c on P2020 it doesn't come up.  Now it'll be
interesting to find out what BQL/ BQL integration in gianfar has to do
with this.

Thanks.
claudiu
