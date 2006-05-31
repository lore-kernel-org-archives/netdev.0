From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection hang problem with 2.6.16.16, e1000.
Date: Wed, 31 May 2006 10:26:03 -0700
Message-ID: <447DD1AB.3030909@candelatech.com>
References: <447DC830.4080201@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:10397 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751749AbWEaR0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 13:26:03 -0400
Received: from [71.112.216.116] (pool-71-112-216-116.sttlwa.dsl-w.verizon.net [71.112.216.116])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k4VHQ2Hu032035
	for <netdev@vger.kernel.org>; Wed, 31 May 2006 10:26:02 -0700
To: NetDev <netdev@vger.kernel.org>
In-Reply-To: <447DC830.4080201@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Kernel is 2.6.16.16 with my patches, including a patch to the
> e1000.  I also rebuilt a fresh kernel with only the attached
> send-to-self patch.  I see the hang, but there was no OOM messages,
> probably because the machine was freshly rebooted and had plenty
> of buffers available.  I will try to reproduce this with some other
> NICs next...

The same problem happens with a single TCP connection between two
copper 10/100/1000 intel ports on the FC2 dual-xeon 32-bit machine.


I tried a dual-core AMD system running 64-bit kernel and FC5.  This kernel
is running my complete set of patches (against 2.6.16.16).

I can reproduce with Intel pro/1000 on this dual-core system when I up the rate to 400Mbps
and do 50,000 byte writes (can only get 125Mbps with 5000 byte writes on
this system, and it ran at that speed for several minutes w/out problem.)

I can also reproduce when using the tg3 adapters, but the tg3 can only run at about
220Mbps, even with the larger write size.  This slower speed could be because of bus
issues or the VLAN I used for one end of the connection.  I could not see this problem with tg3 untill
I yanked the cable a few times and then ran the connection through my network
emulator (which will cause a bit of latency and some dropped packets).  The tethereal
output looks slightly different, but I think this is just because it is a different
version from the older FC2 system from my previous email.

   0.399107  192.168.1.3 -> 192.168.1.2  TCP 33020 > 33019 [ACK] Seq=4294967248 Ack=48 Win=11998 Len=0 TSV=943608 TSER=842823
   0.400565  192.168.1.2 -> 192.168.1.3  TCP 33019 > 33020 [ACK] Seq=0 Ack=0 Win=11998 Len=0 TSV=943608 TSER=842824
   0.400764  192.168.1.3 -> 192.168.1.2  TCP 33020 > 33019 [ACK] Seq=4294967248 Ack=48 Win=11998 Len=0 TSV=943608 TSER=842823
   0.400948  192.168.1.2 -> 192.168.1.3  TCP 33019 > 33020 [ACK] Seq=0 Ack=0 Win=11998 Len=0 TSV=943608 TSER=842824
   0.408851  192.168.1.3 -> 192.168.1.2  TCP 33020 > 33019 [ACK] Seq=4294967248 Ack=48 Win=11998 Len=0 TSV=943608 TSER=842823
   0.410005  192.168.1.2 -> 192.168.1.3  TCP 33019 > 33020 [ACK] Seq=0 Ack=0 Win=11998 Len=0 TSV=943608 TSER=842824
   0.411524  192.168.1.3 -> 192.168.1.2  TCP 33020 > 33019 [ACK] Seq=4294967248 Ack=48 Win=11998 Len=0 TSV=943608 TSER=842823
   0.450702  192.168.1.2 -> 192.168.1.3  TCP 33019 > 33020 [ACK] Seq=0 Ack=0 Win=11998 Len=0 TSV=943608 TSER=842824


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

