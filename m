From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling
 to mitigate SYN floods
Date: Wed, 30 May 2012 14:20:33 -0700
Message-ID: <4FC68F21.1040402@hp.com>
References: <20120528115102.12068.79994.stgit@localhost.localdomain> <m2bol6lqxo.fsf@firstfloor.org> <1338360073.2760.81.camel@edumazet-glaptop> <201205301013.10797.hans.schillstrom@ericsson.com> <1338366288.2760.115.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:37145 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727Ab2E3VUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 17:20:40 -0400
In-Reply-To: <1338366288.2760.115.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2012 01:24 AM, Eric Dumazet wrote:
> On Wed, 2012-05-30 at 10:03 +0200, Hans Schillstrom wrote:
>
>> We have this option running right now, and it gave slightly higher values.
>> The upside is only one core is running at 100% load.
>>
>> To be able to process more SYN an attempt was made to spread them with RPS to
>> 2 other cores gave 60% more SYN:s per sec
>> i.e. syn filter in NIC sending all irq:s to one core gave ~ 52k syn. pkts/sec
>> adding RPS and sending syn to two other core:s gave ~80k  syn. pkts/sec
>> Adding more cores than two didn't help that much.
>
> When you say 52.000 pkt/s, is that for fully established sockets, or
> SYNFLOOD ?
>
> 19.23 us to handle _one_ SYN message seems pretty wrong to me, if there
> is no contention on listener socket.

It may still be high, but a very quick netperf TCP_CC test over loopback 
on a W3550 system running a 2.6.38 kernel shows:

raj@tardy:~/netperf2_trunk/src$ ./netperf -t TCP_CC -l 60 -c -C
TCP Connect/Close TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
localhost.localdomain () port 0 AF_INET
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  %      %      us/Tr   us/Tr

16384  87380  1       1      60.00   21515.29   30.68  30.96  57.042  57.557
16384  87380

57 microseconds per "transaction" which in this case is establishing and 
tearing-down the connection, with nothing else (no data packets) makes 
19 microseconds for a SYN seem perhaps not all that beyond the realm of 
possibility?

rick jones
