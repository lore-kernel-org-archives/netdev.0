From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Mon, 04 Jun 2012 13:12:20 -0700
Message-ID: <4FCD16A4.9070705@candelatech.com>
References: <4FCCFE76.3060304@candelatech.com> <1338838352.2760.1906.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55011 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab2FDUMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 16:12:21 -0400
In-Reply-To: <1338838352.2760.1906.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2012 12:32 PM, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 11:29 -0700, Ben Greear wrote:
>> I'm going some TCP performance testing on wifi ->  LAN interface connections.  With
>> UDP, we can get around 250Mbps of payload throughput.  With TCP, max is about 80Mbps.
>>
>> I think the problem is that there are way too many ACK packets, and bi-directional
>> traffic on wifi interfaces really slows things down.  (About 7000 pkts per second in
>> upload direction, 2000 pps download.  And the vast majority of the download pkts
>> are 66 byte ACK pkts from what I can tell.)
>>
>> Kernel is 3.3.7+
>>
>> Anyone know of any tuning parameters that would let the receiving socket wait a
>> bit longer and send more ACK data in fewer packets?
>
> Well, thats half duplex days...

WiFi is still half-duplex, and isn't changing any time soon I think.

> There is the ACK every 2 packets rule of thumb, so that tcp sender can
> increase its cwnd.
>
> Then, some folks tried submitting patches to make '2' more like 10 or
> 15, but this went nowhere.
>
> Other idea is to arm a timer and defer ACK sending, in the hope we
> receive another packet very soon.

 From a quick read of Daniel's patch..it seems there is already a
timer that could be used for this?

> That could be done with a special qdisc, sort of netem...

That sounds like a horrible hack :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
