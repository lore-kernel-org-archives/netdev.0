From: Martin Rusko <martin.rusko@gmail.com>
Subject: Re: Sending undersized ARP packets with VXLAN L3 interface
Date: Thu, 11 Sep 2014 18:16:44 +0200
Message-ID: <CAMYYbY7PXt=-eJ2BU1YO6biEL1F3NRq-=6NdQ-nJGmhXXOWKbA@mail.gmail.com>
References: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com>
	<CAHA+R7Ok6K_9U6RCZkSLCuVXtFG4Zs60FQKFZMu-v2yK581hog@mail.gmail.com>
	<53FE1AC3.5030409@gmail.com>
	<20140827114209.3a9d3761@urahara>
	<53FE2738.30702@gmail.com>
	<CAMYYbY4KHTkkv6peT14S8mCzcQJ8wROnHWj5tMy563H-w79KMg@mail.gmail.com>
	<53FE3E5C.8020804@gmail.com>
	<CAMYYbY7vCqpW7pqy=a7O=9YnPM=R1Ta2gfXdZEqrmyK-P-Akdw@mail.gmail.com>
	<CAMYYbY7pp4WDBnFmoeK6D9BdUnuZ-v5fw1hH2V6zxM9GRRK=Mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:47239 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbaIKQQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 12:16:47 -0400
Received: by mail-vc0-f174.google.com with SMTP id hy10so5999118vcb.5
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 09:16:45 -0700 (PDT)
In-Reply-To: <CAMYYbY7pp4WDBnFmoeK6D9BdUnuZ-v5fw1hH2V6zxM9GRRK=Mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 1, 2014 at 4:26 PM, Martin Rusko <martin.rusko@gmail.com> wrote:
>>>>>>
>>>>>> No. The short frame is perfectly valid, over the VXLAN.
>>>>>> The system doing the decap and forwarding should be where any padding is added if necessary.
>>>>>>
>>>>
>>>> Well, RFC 7348 is not dealing with padding at all. Both deployment
>>>> scenarios listed in RFC, as well as most of the existing real life
>>>> deployments today (in my opinion) use VXLAN for bridged traffic. In
>>>> other words, frame encapsulated by VTEP is received first over some
>>>> ethernet interface (physical or virtual) which implies that the frame
>>>> is at least 64 bytes long already.
>>>>
>>>> Perhaps we're going to see more VXLAN interfaces in L3 mode, yet it
>>>> might be safer not to count on receiving VTEP doing the right thing
>>>> (pad small packets with zeros).
>>>>
>>>>>
>>>>> If that's the case, then Martin is most likely seeing a HW bug on the switch.
>>>>> I wonder how common such a bug might be?
>>>>>
>>>>> -vlad
>>>>>
>>>>
>>>> I see this on Vmware distributed virtual switch. Perhaps soon I will
>>>> be able to test it against HP 5930 switch. I'm going to try how Linux
>>>> bridge copes with it, now.
[...]
> Haven't had chance to test it with hardware switch yet, so it's only
> causing problems with Vmware so far, when inner ethernet frame is not
> padded.

Perhaps nobody is reading this anymore, but at least it will make it
to the archive for reference. :-)

So I tested also how HP 5930 switch handles small inner frames. They
were padded. So it's in line with what Stephen said, that the
receiving VTEP should pad frames to minimum size before sending them
to the medium where size check is enforced.

Regards,
Martin
