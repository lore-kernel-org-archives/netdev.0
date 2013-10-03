From: Ben Greear <greearb@candelatech.com>
Subject: Re: Ideas on why using WPA2 encryption speeds up many TCP connections?
Date: Thu, 03 Oct 2013 12:17:12 -0700
Message-ID: <524DC2B8.905@candelatech.com>
References: <524DB6F6.6020405@candelatech.com> <524DBC93.1070400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57776 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab3JCTRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:17:20 -0400
In-Reply-To: <524DBC93.1070400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2013 11:50 AM, Rick Jones wrote:
> On 10/03/2013 11:27 AM, Ben Greear wrote:
>> I'm seeing something a bit strange and wondering if anyone had an
>> opinion on why...
>>
>> I am testing up to 200 wifi station systems, each with a TCP connection
>> running on them (download only, from VAP to stations).
>>
>> Without encryption (ie, open network), I see total throughput go from
>> about 108Mbps down to 69Mbps as I add more stations (I add 25 at a time,
>> so the 108Mbps is with 25 active, and 69Mbps is with 200 active).
>>
>> However, if I enable encryption, the throughput is actually higher
>> (111Mbps to 71Mbps).  I'm doing encryption in software, so it adds a fair
>> bit of CPU load in this test.  The numbers bounce around since this is
>> wifi after all, but in general encryption tends to win reliably in this
>> test.
>>
>> When testing with a single station (and 5 tcp streams with jacked up
>> snd/rcv buffers) the open networks perform significantly better at total throughput:
>> 263Mbps vs 246Mbps.
>>
>> Maybe the extra delay for decryption increases odds that GRO will take
>> affect for the many, slower streams (and maybe that will decrease ACK
>> traffic?)
>>
>> Any other ideas?
>
> Fewer times two or more stations step on one another?  The recievers will only try to transmit when they receive data.  Modulo timing, if the individual
> downloads are a bit slower, less chance of the receivers looking to send ACKs back through at the same time?  Got any low-level stats for the health and well
> being of the wireless network?

The tcp connection stats are taken after running for 60 seconds, and I take 3-sec running averages
as well as 60 second averages.  So, I think that it would have to be total decrease in ACKs,
not just timing, to make a difference.  The 3 and 60 second stats show consistently higher throughput
with encryption when using 25+ stations/connections.

Also, it works out that the sending sockets all sort of send randomly as they
are able, so I don't think there would be any particular ACK flood seen..

I have great quantities of low level stats, but I have not dug into them in detail
just yet.  In general, my RF environment in this test is fairly controlled, as
I am cabling the systems using good semi-rigid SMA cables and an RF attenuator.
There will be some external interference of course, as they are not in an
isolation chamber.


As for the difference in 1 stations vs 25+, then it is very likely related to
low level things like MPDU working better with a single station, and probably
better ACK avoidance (I recall about 20kpps download, 4kpps upload in a previous
test with a single station, which indicates to me we must not be acking every
packet-on-the-air..somehow).

(For grins, I played with the delayed-ack-segs from an out-of-tree patch and
can get TCP throughput up to 300Mbps by setting delayed ack segs to 64 in
single station/5 stream, open network test).

Thanks,
Ben

>
> rick jones


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
