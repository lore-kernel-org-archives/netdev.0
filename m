From: sdncurious <sdncurious@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 9 Feb 2017 11:42:45 -0800
Message-ID: <CAHoNx5_S3dCSbqfHT+i=VMqw11PcEMA2bBY8Sbp=pAFAhBL6CA@mail.gmail.com>
References: <20170207140144.GA11233@localhost> <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
        netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35095 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752355AbdBITvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:51:54 -0500
Received: by mail-io0-f182.google.com with SMTP id j18so27890018ioe.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 11:51:25 -0800 (PST)
In-Reply-To: <20170209110941.GA1449@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>> > 5) new SO_TIMESTAMPING options to get transposed RX timestamps
>> >
>> >    PTP uses preamble RX timestamps, but NTP works with trailer RX
>> >    timestamps. This means NTP implementations currently need to
>> >    transpose HW RX timestamps. The calculation requires the link speed
>> >    and the length of the packet at layer 2. It seems this can be
>> >    reliably done only using raw sockets. It would be very nice if the
>> >    kernel could tranpose the timestamps automatically.
>>
>> Impossible, because the link speed may change between the time when
>> the MAC receives the data the kernel gets around to calculating the
>> time stamp.
>
> I think that would be an acceptable limitation. The application
> certainly couldn't do a better job than the kernel and it won't have
> to use raw sockets.
>

As you are using HW that supports NTP time stamping won't it by
default time stamp the receiving packet correctly at the CRC ? Or if
someone came out with such a HW than what ?
I am still at a loss as to why transpose is required in case of HW
time stamping. If STF is used for both Tx and Rx time stamping the
timing is absolutely correct. Any  delay in the PHY is nothing more
than usual kernel processing delay,  which NTP should be able to deal
with when trying to calculate the round trip time, unless there is an
issue with the algorithm.

The application can even calculate the complete delay in kernel
processing if we provide another time stamp when the packet is read by
the application. That seems to provide more accuracy and seems like a
better idea.


RMS.
