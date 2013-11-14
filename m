From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel
 > 3.10
Date: Thu, 14 Nov 2013 16:13:38 -0500
Message-ID: <52853D02.70804@gmail.com>
References: <52838590.5070806@profihost.ag> <20131113141244.GM19702@redhat.com> <52838AC8.8070005@profihost.ag> <52839540.6020908@gmail.com> <5283980D.7020508@profihost.ag> <20131113162136.GP19702@redhat.com> <5283B500.9040408@gmail.com> <5283DC91.1010402@profihost.ag> <52843EEA.3020905@redhat.com> <52848010.8030103@profihost.ag> <20131114122928.GV19702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, Linux Netdev List <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:34842 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937Ab3KNVNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:13:43 -0500
Received: by mail-qa0-f51.google.com with SMTP id i13so39319qae.17
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 13:13:41 -0800 (PST)
In-Reply-To: <20131114122928.GV19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 07:29 AM, Veaceslav Falico wrote:
> On Thu, Nov 14, 2013 at 08:47:28AM +0100, Stefan Priebe - Profihost AG
> wrote:
>> Hi,
>>
>>> eth2
>>>      \
>>>       -- bond1 -- vmbr1
>>>      /     \
>>> eth3        ----- bond1.3000 --- vmbr1v3000
>>>                                      \ ---- tap114i1
>>
>> thos one works fine now.
>>
>>
>>> eth2
>>>      \
>>>       -- bond1 -- vmbr1
>>>      /              \
>>> eth3                 \ vmbr1.3000
>>>                            \ ---- tap114i1
>>
>> this one does not. Another note to this one. It also never worked on
>> RHEL6 - it started working with about 2.6.39 and stopped with 3.9 or
>> 3.10. But it was the only one where gvrp on vlans had worked.
>
> bridge device in this config is neither master nor slave, if I read it
> correctly.

Bridge doesn't propagate rx_flags to lower-level devices.  It 
automatically set all lower devices to promisc mode.

So, in the second case above, eth2 and eth3 have to be in promisc, but
nothing else does.  I am not sure I understand Stefans notation though
wrt to how vmbr1.3000 and tap114i1 are configured.  Stefan,  can you
elaborate?

Thanks
-vlad
>
> You might want to try my patch to see if it works (my previous email).
>
>>
>> Greets,
>> Stefan
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
