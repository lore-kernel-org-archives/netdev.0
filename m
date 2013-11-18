From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel
 > 3.10
Date: Mon, 18 Nov 2013 08:37:55 +0100
Message-ID: <5289C3D3.8080003@profihost.ag>
References: <52838590.5070806@profihost.ag>	<20131113141244.GM19702@redhat.com>	<52838AC8.8070005@profihost.ag>	<52839540.6020908@gmail.com>	<5283980D.7020508@profihost.ag>	<20131113162136.GP19702@redhat.com>	<5283B500.9040408@gmail.com>	<5283DC91.1010402@profihost.ag>	<52843EEA.3020905@redhat.com>	<52848010.8030103@profihost.ag>	<20131114122928.GV19702@redhat.com>	<52853D02.70804@gmail.com>	<5287DD79.5060906@profihost.ag> <CAGCdqXEQwHy_q+qWQf9oYTkr0v_HXLY-nudjW=4ghYpB+o3H1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:42143 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab3KRHh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 02:37:58 -0500
In-Reply-To: <CAGCdqXEQwHy_q+qWQf9oYTkr0v_HXLY-nudjW=4ghYpB+o3H1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 17.11.2013 04:41, schrieb Vladislav Yasevich:
> On Sat, Nov 16, 2013 at 4:02 PM, Stefan Priebe <s.priebe@profihost.ag> wrote:
>> Am 14.11.2013 22:13, schrieb Vlad Yasevich:
>>
>>> On 11/14/2013 07:29 AM, Veaceslav Falico wrote:
>>>>
>>>> On Thu, Nov 14, 2013 at 08:47:28AM +0100, Stefan Priebe - Profihost AG
>>>> wrote:
>>>>>
>>>>> Hi,
>>>>>
>>>>>> eth2
>>>>>>      \
>>>>>>       -- bond1 -- vmbr1
>>>>>>      /     \
>>>>>> eth3        ----- bond1.3000 --- vmbr1v3000
>>>>>>                                      \ ---- tap114i1
>>>>>
>>>>>
>>>>> thos one works fine now.
>>>>>
>>>>>
>>>>>> eth2
>>>>>>      \
>>>>>>       -- bond1 -- vmbr1
>>>>>>      /              \
>>>>>> eth3                 \ vmbr1.3000
>>>>>>                            \ ---- tap114i1
>>>>>
>>>>>
>>>>> this one does not. Another note to this one. It also never worked on
>>>>> RHEL6 - it started working with about 2.6.39 and stopped with 3.9 or
>>>>> 3.10. But it was the only one where gvrp on vlans had worked.
>>>>
>>>>
>>>> bridge device in this config is neither master nor slave, if I read it
>>>> correctly.
>>>
>>>
>>> Bridge doesn't propagate rx_flags to lower-level devices.  It
>>> automatically set all lower devices to promisc mode.
>>>
>>> So, in the second case above, eth2 and eth3 have to be in promisc, but
>>> nothing else does.  I am not sure I understand Stefans notation though
>>> wrt to how vmbr1.3000 and tap114i1 are configured.  Stefan,  can you
>>> elaborate?
>>
>>
>> Sorry . means vlan - so vmbr1.3000 is just a vlan on top of vmbr1. *brX is a
>> bridge. Bond is a lacp bond ;-)
>>
> 
> Ok.  I got that.  But where is tap attached?  You are showing it
> attached to the vlan,
> but you can't do that unless its a macvtap.

Why not? It was working until 3.9 - but with the patch in this thread
the first method adding a bridge on top of the bond works fine - so this
is OK for me too.

Greets,
Stefan
