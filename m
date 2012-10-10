From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Tue, 09 Oct 2012 21:59:27 -0700
Message-ID: <507500AF.4080209@gmail.com>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl> <1349677373.21172.2756.camel@edumazet-glaptop> <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl> <1349689640.21172.3008.camel@edumazet-glaptop> <80bb011e8f1289218087633fd7b115ea@justnet.pl> <5072C063.6000302@tomt.net> <1349698406.21172.3168.camel@edumazet-glaptop> <5072C7F4.1090002@tomt.net> <5072CE29.5010504@tomt.net> <d29932d70fa2025a8b87b053d9d99953@justnet.pl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andre Tomt <andre@tomt.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65013 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185Ab2JJE7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 00:59:31 -0400
In-Reply-To: <d29932d70fa2025a8b87b053d9d99953@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2012 12:56 PM, Nie=C5=9Bcierowicz Adam wrote:
> W dniu 08.10.2012 14:59, Andre Tomt napisa=C5=82(a):
>
>> On 08. okt. 2012 14:32, Andre Tomt wrote:
>>
>>> On 08. okt. 2012 14:13, Eric Dumazet wrote:
>>>
>>>> On Mon, 2012-10-08 at 14:00 +0200, Andre Tomt wrote:
>>>>
>>>>> On 08. okt. 2012 12:49, Nie=C5=9Bcierowicz Adam wrote:
>>>>>
>>>>>> W dniu 08.10.2012 11:47, Eric Dumazet napisa=C5=82(a):
>>>>>>
>>>>>>> Anyway you dont say where are drops, (ifconfig give us very few
>>>>>>> drops)
>>>>>> you can see no losses(drop), but a temporary decline in traffic
>>>>>> on the interface to 0kb/s
>>>>> This sounds very familiar, could it be something similar to:
>>>>> http://marc.info/?l=3Dlinux-netdev&m=3D134594936016796&w=3D3 [1] =
The chip
>>>>> seems to be of the same family (though not model)
>>>> Yes, but Adam says 3.4.1 already has a problem, while commit
>>>> 2cb7a9cc008c25dc03314de563c00c107b3e5432 is in 3.5 only. Since Ada=
m
>>>> uses Intel e1000e, it could be the BQL related problem.
>>> The other chips have had DMA burst flag enabled for longer, so that=
 he
>>> sees the same problem in 3.4 while I'm not makes sense. Hmm, as 3.4=
 is
>>> when BQL went in (IIRC) it seems very likely that this BQL issue is=
 the
>>> problem for both of us.
>>
>> To clarify; I think the DMA burst flag in the driver triggers the BQ=
L
>> related issue. Judging by the patchwork link for wthresh=3D1 this se=
ems
>> very related indeed.
>>
>> Removing the FLAG2_DMA_BURST flag for 82574 in the driver works for =
me.
>> Adam, it might be worth testing out a build on your system too with =
the
>> flag removed. If you try the attached patch (for 3.6, probably OK fo=
r
>> 3.5) and the problem dissapears, we are probably at least talking ab=
out
>> the same bug.
>
> after applying the patch everything looks good, no visible loss
>
> Do you expect to correct the bug in mainline?=20
Jesse Brandenburg is working on a patch for upstream currently to fix=20
the issue.
