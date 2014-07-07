From: Chad Reese <kreese@cavium.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Mon, 07 Jul 2014 14:03:38 -0700
Message-ID: <53BB0B2A.3060708@cavium.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com> <1404416380-3545-2-git-send-email-willemb@google.com> <20140705201851.GE3869@localhost.localdomain> <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com> <20140707184700.GA1610@localhost.localdomain> <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com> <53BAF8AC.6010907@cavium.com> <20140707201156.GA10265@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:56136 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaGGVDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 17:03:41 -0400
Received: by mail-ie0-f171.google.com with SMTP id rp18so1641502iec.30
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 14:03:40 -0700 (PDT)
In-Reply-To: <20140707201156.GA10265@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2014 01:11 PM, Richard Cochran wrote:
> On Mon, Jul 07, 2014 at 12:44:44PM -0700, Chad Reese wrote:
>>
>> A hardware timer used for ethernet timestamps is completely
>> independent from the kernel's software view of time. Since the
>> hardware timestamps are only exposed in the driver, how can they be
>> correlated with system time? If the driver doesn't do it, then
>> nobody else knows how.
>
> Um, implement a PTP Hardware Clock device?

Octeon does support using the 1588 clock as the kernel's clock source. 
Unfortunately most people don't seem to want to use it. I have no idea why.

> Don't reimplement clock servos in your driver. Instead, leave that to
> the PTP stack (like using linuxptp's phc2sys).

I obviously did it wrong. The one line comment in 
Documentation/networking/timestamping.txt was not enough for me to 
figure out the proper usage of syststamp.

>> For Octeon, you can optionally use the hardware timestamp as the
>> system clock reference. Most people don't, but it is the only way to
>> get the system time to be accurate. 1588 can synchronize two Octeon
>> boards to less than 1ns for the hardware timer. The Linux software
>> timers is always farther off.
>
> 1588 cannot synchronize boards unless you expose the clock to the
> userland PTP stack. Why don't you do that?

I was trying to stick with standard linux userspace APIs. People have no 
interest in the PTP clock at all. All they want is for the standard 
system time to be correct.

Chad

-- 

Chad Reese <kreese@cavium.com>
Cavium Networks
Phone: 408 - 943 - 7183
Cell: 321 - 438 - 7753
