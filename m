From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Mon, 04 Jun 2012 13:09:11 -0700
Message-ID: <4FCD15E7.4080700@candelatech.com>
References: <4FCCFE76.3060304@candelatech.com> <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49730 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2FDUJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 16:09:14 -0400
In-Reply-To: <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2012 12:22 PM, Daniel Baluta wrote:
> On Mon, Jun 4, 2012 at 9:29 PM, Ben Greear<greearb@candelatech.com>  wrote:
>> I'm going some TCP performance testing on wifi ->  LAN interface connections.
>>   With
>> UDP, we can get around 250Mbps of payload throughput.  With TCP, max is
>> about 80Mbps.
>>
>> I think the problem is that there are way too many ACK packets, and
>> bi-directional
>> traffic on wifi interfaces really slows things down.  (About 7000 pkts per
>> second in
>> upload direction, 2000 pps download.  And the vast majority of the download
>> pkts
>> are 66 byte ACK pkts from what I can tell.)
>>
>> Kernel is 3.3.7+
>>
>> Anyone know of any tuning parameters that would let the receiving socket
>> wait a
>> bit longer and send more ACK data in fewer packets?
>
> An ACK is generated after every second full sized segment or a timeout
> expires.
>
> Currently, there is no way to tune these parameters. Here is an experimental
> patch [1]. If anyone, thinks that this patch has a chance to get accepted
> I will be happily try to further improve it.

It looks like it could be useful for my case, but I would also want
per-socket options to set the min/max ack delay so that the settings
are not just system-wide.

I can at least test this, and perhaps even hack on the code if
you are not interested in the per-socket settings...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
