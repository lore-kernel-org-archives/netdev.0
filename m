From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Thu, 07 Jun 2012 07:41:50 -0700
Message-ID: <4FD0BDAE.7030809@candelatech.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F3C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Baluta <dbaluta@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56231 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760825Ab2FGOl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 10:41:57 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F3C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2012 05:20 AM, David Laight wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org
>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Greear
>> Sent: 07 June 2012 05:16
>> To: Daniel Baluta
>> Cc: netdev
>> Subject: Re: tcp wifi upload performance and lots of ACKs
>>
>> On 06/04/2012 12:22 PM, Daniel Baluta wrote:
>>> On Mon, Jun 4, 2012 at 9:29 PM, Ben Greear<greearb@candelatech.com>
> wrote:
>>>> I'm going some TCP performance testing on wifi ->   LAN interface
> connections.
>>>>    With
>>>> UDP, we can get around 250Mbps of payload throughput.  With TCP,
> max is
>>>> about 80Mbps.
>>>>
>>>> I think the problem is that there are way too many ACK packets, and
>>>> bi-directional
>>>> traffic on wifi interfaces really slows things down.  (About 7000
> pkts per
>>>> second in
>>>> upload direction, 2000 pps download.  And the vast majority of the
> download
>>>> pkts
>>>> are 66 byte ACK pkts from what I can tell.)
>>
>>> [1] http://marc.info/?l=linux-netdev&m=131983649130350&w=2
>>
>> After a bit more playing, I did notice a reliable 5% increase in
>> traffic (200Mbps ->  210Mbps) from changing the delack segments
>> to 20 from the default of 1.  That is enough to be useful to me,
>> and there may be more significant gains to be found...
>> I haven't done a full matrix of testing yet.
>
> Does this delaying of acks have a detrimental effect on the
> sending end?
> I've seen very bad interactions between delayed acks and
> (I believe) the 'slow start' code on connections with
> one-directional data, Nagle disabled and very low RTT.
>
> What I saw was the sender sending 4 data packets, then
> sitting waiting for an ack - in spite of accumulating
> several kB of data to send.
>
> Delaying acks further will only make this worse.

I'm sure it's not for everyone in all cases.  In my case, I'm
sending long-term bulk transfer, at high speeds, over wifi network
which has some latency.  Tested one-way traffic so far.

With the patch and delayed acks, I get more sender throughput than
without (200Mbps -> 210Mbps).

Thanks,
Ben

>
> 	David
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
