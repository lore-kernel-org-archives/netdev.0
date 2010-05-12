From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: RE: get beyond 1Gbps with pktgen  on 10Gb nic?
Date: Tue, 11 May 2010 21:00:23 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85C81@MILEXCH2.ds.jdsu.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net>
 <1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
 <4BE97DD7.7000704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og104.obsmtp.com ([64.18.2.161]:55073 "HELO
	exprod7og104.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750736Ab0ELEJW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 00:09:22 -0400
In-Reply-To: <4BE97DD7.7000704@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just used multi netperf instances to reach 900K pps/8Gb+ traffic on the Broadcom 10G nic:

command:

for i in 1 2 3 4 5 6 7 8 9 10
do
netperf -l 60 -H 192.168.0.53 -- -m 60 -s 100M -S 100M &
done

the msg size was assigned as 64 bytes, but when I checked the file captured by tcpdump,
found that netperf sent many frames which are large than 64 bytes(i.e.4000-10K+ bytes) and these frames 
were truncated by tcpdump.

so that the actual avg packet size is around 1500 bytes, but what I want is avg packet: 300-400 bytes and reach 5Gb+.

does it make sense?

thanks
jon


-----Original Message-----
From: Ben Greear [mailto:greearb@candelatech.com] 
Sent: Tuesday, May 11, 2010 11:55 PM
To: Ben Hutchings
Cc: Jon Zhou; netdev@vger.kernel.org
Subject: Re: get beyond 1Gbps with pktgen on 10Gb nic?

On 05/11/2010 06:35 AM, Ben Hutchings wrote:
> On Tue, 2010-05-11 at 06:13 -0700, Jon Zhou wrote:
>> hi there:
>>
>> anyone can get beyond 1Gbps with pktgen or other SW traffic generator with 10Gb nic(intel 82599 or BCM 57711)?
>> found that some one had met similar situation with broadcom 10G nic but no solution yet
>
> I don't know about those specific controllers, but you should be able to
> achieve close to 10G line rate with netperf's TCP_STREAM on any recent
> PC server.  UDP throughput tends to be poorer as there is less support
> for offloading segmentation and reassembly.  Performance may also be
> constrained by PCI Express bandwidth (you need a real 8-lane slot) and
> memory bandwidth (a single memory bank may not be enough).

We can easily push right at 10Gbps full-duplex on two ports (sending to self)
with a 2-port 82599 NIC, 3.3Ghz quad-core Intel core i7 6GT/s processor, etc.

In fact, recent testing with a 2-port 10G NIC and a bunch of intel 1G ports showed about
50Gbps aggregate bandwidth across the network on such a system.   (We were using 9000 MTU
for the 50Gbps test, but can reach 10G send-to-self with 1500 MTU on the 10G ports by themselves.)

This is all using a slightly modified pktgen, but normal pktgen should do just fine.

Thanks,
Ben

>
> Ben.
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
