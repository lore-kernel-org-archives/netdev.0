From: Martin Rusko <martin.rusko@gmail.com>
Subject: Re: Sending undersized ARP packets with VXLAN L3 interface
Date: Mon, 1 Sep 2014 16:26:56 +0200
Message-ID: <CAMYYbY7pp4WDBnFmoeK6D9BdUnuZ-v5fw1hH2V6zxM9GRRK=Mg@mail.gmail.com>
References: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com>
	<CAHA+R7Ok6K_9U6RCZkSLCuVXtFG4Zs60FQKFZMu-v2yK581hog@mail.gmail.com>
	<53FE1AC3.5030409@gmail.com>
	<20140827114209.3a9d3761@urahara>
	<53FE2738.30702@gmail.com>
	<CAMYYbY4KHTkkv6peT14S8mCzcQJ8wROnHWj5tMy563H-w79KMg@mail.gmail.com>
	<53FE3E5C.8020804@gmail.com>
	<CAMYYbY7vCqpW7pqy=a7O=9YnPM=R1Ta2gfXdZEqrmyK-P-Akdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:54987 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258AbaIAO05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:26:57 -0400
Received: by mail-vc0-f172.google.com with SMTP id ij19so5662845vcb.3
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 07:26:56 -0700 (PDT)
In-Reply-To: <CAMYYbY7vCqpW7pqy=a7O=9YnPM=R1Ta2gfXdZEqrmyK-P-Akdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>>
>>>>> No. The short frame is perfectly valid, over the VXLAN.
>>>>> The system doing the decap and forwarding should be where any padding is added if necessary.
>>>>>
>>>
>>> Well, RFC 7348 is not dealing with padding at all. Both deployment
>>> scenarios listed in RFC, as well as most of the existing real life
>>> deployments today (in my opinion) use VXLAN for bridged traffic. In
>>> other words, frame encapsulated by VTEP is received first over some
>>> ethernet interface (physical or virtual) which implies that the frame
>>> is at least 64 bytes long already.
>>>
>>> Perhaps we're going to see more VXLAN interfaces in L3 mode, yet it
>>> might be safer not to count on receiving VTEP doing the right thing
>>> (pad small packets with zeros).
>>>
>>>>
>>>> If that's the case, then Martin is most likely seeing a HW bug on the switch.
>>>> I wonder how common such a bug might be?
>>>>
>>>> -vlad
>>>>
>>>
>>> I see this on Vmware distributed virtual switch. Perhaps soon I will
>>> be able to test it against HP 5930 switch. I'm going to try how Linux
>>> bridge copes with it, now.
>>
>> Linux bridge will do just fine as it will pass the frame off to the hw driver
>> which should pad things appropriately.
>>
>> -vlad
>>
>
> I can confirm that, now.

I also tried a setup with Xen hypervisor and HVM guest connected to
bridge with vxlan interface. In any combination I tried, it pretty
much didn't care about the ethernet packet size.

Haven't had chance to test it with hardware switch yet, so it's only
causing problems with Vmware so far, when inner ethernet frame is not
padded.

>
> Vlad, I'm going to recompile 3.16.1 kernel with your patch.
>

Vlad's patch works perfectly. I asked the authors of RFC 7348 to
eventually clarify if any padding should be required for the inner
frames. Shall the patch be included in the mainline kernel or not?

/Martin
