From: Chad Reese <kreese@caviumnetworks.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Tue, 08 Jul 2014 00:42:46 -0700
Message-ID: <53BBA0F6.3090003@caviumnetworks.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com> <1404416380-3545-2-git-send-email-willemb@google.com> <20140705201851.GE3869@localhost.localdomain> <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com> <20140707184700.GA1610@localhost.localdomain> <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com> <53BAF8AC.6010907@cavium.com> <20140707201156.GA10265@localhost.localdomain> <53BB0B2A.3060708@cavium.com> <20140708060441.GB3977@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Daney <david.daney@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>,
	Chad Reese <kreese@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:52345 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbaGHHt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 03:49:26 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so6882845pad.21
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 00:49:25 -0700 (PDT)
In-Reply-To: <20140708060441.GB3977@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2014 11:04 PM, Richard Cochran wrote:
> On Mon, Jul 07, 2014 at 02:03:38PM -0700, Chad Reese wrote:
>> On 07/07/2014 01:11 PM, Richard Cochran wrote:
>>> Don't reimplement clock servos in your driver. Instead, leave that to
>>> the PTP stack (like using linuxptp's phc2sys).
>>
>> I obviously did it wrong. The one line comment in
>> Documentation/networking/timestamping.txt was not enough for me to
>> figure out the proper usage of syststamp.
>
> Sorry about not having clearly deprecated syststamp. We'll do that now.
> Next time, putting the PTP maintainer on CC will help catch such things.
>
>> I was trying to stick with standard linux userspace APIs.
>
> There is a standard PTP hardware clock subsystem and API, as explained
> in Documentation/ptp/ptp.txt.
>
>> People
>> have no interest in the PTP clock at all. All they want is for the
>> standard system time to be correct.
>
> You can't have the time correct unless you synchronize it to
> something. That is what NTP and PTP are all about. When using a PTP
> hardware clock, it is necessary to synchronize the Linux system time
> to it. The right way to accomplish this is using a userland PTP
> stack, and the wrong way is to implement a servo in every last MAC
> driver.

You keep saying I implemented a clock servo in the MAC driver. I didn't, 
as is apparent in the code. The only kludge was a conversion from the 
PTP clock to system time with a simple offset function. I will fully 
admit it wasn't great, but it was good enough.

> What I don't understand is, how does your device get the PTP time
> without running the PTP protocol?

I wrote a PTPv2 daemon for Cavium that ran in userspace. It implemented 
all the v2 spec with support for both IP and 802.3 transport. This was 
done from scratch as there wasn't an opensource PTPv2 daemon at the 
time. All this work actually started before there was any PTP timestamp 
support in the kernel. I originally started writing PTP to run on bare 
metal.

> How can your device work without implementing a PTP clock? What am I
> missing?

I'm guessing the details of our PTP implementation are not available to 
the opensource community. It was packaged as a product by Cavium's 
marketing along with other software to support base stations.

Chad
