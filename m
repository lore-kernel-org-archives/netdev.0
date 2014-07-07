From: Chad Reese <kreese@cavium.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Mon, 07 Jul 2014 12:44:44 -0700
Message-ID: <53BAF8AC.6010907@cavium.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com> <1404416380-3545-2-git-send-email-willemb@google.com> <20140705201851.GE3869@localhost.localdomain> <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com> <20140707184700.GA1610@localhost.localdomain> <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: Willem de Bruijn <willemb@google.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:43502 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaGGTos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 15:44:48 -0400
Received: by mail-ie0-f175.google.com with SMTP id at20so1305410iec.20
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 12:44:47 -0700 (PDT)
In-Reply-To: <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2014 12:14 PM, Willem de Bruijn wrote:
> On Mon, Jul 7, 2014 at 2:47 PM, Richard Cochran
> <richardcochran@gmail.com> wrote:
>> On Mon, Jul 07, 2014 at 11:34:05AM -0400, Willem de Bruijn wrote:
>>>
>>> The hardware timestamp converted to system time is deprecated? I did
>>> not know that. Because it is largely unused, or for a more fundamental
>>> reason?
>>
>> It is for the fundamental reason that the idea behind it is just plain
>> wrong. MAC drivers are not the place to put clock servos.
>>
>>> If so, the documentation could indeed use an explicit comment. The
>>> definition of skb_shared_hwtstamps.syststamp too. I can write a small
>>> patch independent of this patchset.
>>
>> Please do.
>
> Ok. See below.
>
>>
>>> Unfortunately, a cursory inspection shows one, octeon. While that user
>>> exists and generates such timestamps, I think that the above new flag
>>> should be passed, as well, for API consistency.
>>
>> Ugh, how the heck did that turd get in? Its not like they bothered to
>> include the maintainer on CC. That code must go.
>
> I'm happy to unwind the syststamp part of 3d305850 ("netdev:
> octeon_mgmt: Add hardware timestamp support"). Chad, let me know if
> you object to that. Else, I'll send a patch to you both for review.

A hardware timer used for ethernet timestamps is completely independent 
from the kernel's software view of time. Since the hardware timestamps 
are only exposed in the driver, how can they be correlated with system 
time? If the driver doesn't do it, then nobody else knows how.

For Octeon, you can optionally use the hardware timestamp as the system 
clock reference. Most people don't, but it is the only way to get the 
system time to be accurate. 1588 can synchronize two Octeon boards to 
less than 1ns for the hardware timer. The Linux software timers is 
always farther off.

Chad

-- 

Chad Reese <kreese@cavium.com>
Cavium Networks
Phone: 408 - 943 - 7183
Cell: 321 - 438 - 7753
