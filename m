From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH?] tcp and delayed acks
Date: Wed, 16 Aug 2006 14:37:00 -0700
Message-ID: <44E38FFC.6000108@hp.com>
References: <20060816205532.GF9519@kvack.org> <20060816121112.0c181ac3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56463 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932221AbWHPVi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:38:26 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060816121112.0c181ac3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The point of delayed ack's was to merge the response and the ack on request/response
> protocols like NFS or telnet. It does make sense to get it out sooner though.

Well, to a point at least - I wouldn't go so far as to suggest immediate 
ACKs.

However, I was always under the impression that ACKs were sent (in the 
mythical generic TCP stack) when:

a) there was data going the other way
b) there was a window update going the other way
c) the standalone ACK timer expired.

Does this patch then implement b?  Were there perhaps "holes" in the 
logic when things were smaller than the MTU/MSS?  (-v 2 on the netperf 
command line should show what the MSS was for the connection)

rick jones

BTW, many points scored for including CPU utilization and service demand 
figures with the netperf output :)

> 
> 
>>[All tests run with maxcpus=1 on a 2.67GHz Woodcrest system.]
>>
>>Recv   Send    Send                          Utilization       Service Demand
>>Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
>>Size   Size    Size     Time     Throughput  local    remote   local   remote
>>bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
>>
>>Base (2.6.17-rc4):
>>default send buffer size
>>netperf -C -c
>> 87380  16384  16384    10.02      14127.79   99.90    99.90    0.579   0.579 
>> 87380  16384  16384    10.02      13875.28   99.90    99.90    0.590   0.590 
>> 87380  16384  16384    10.01      13777.25   99.90    99.90    0.594   0.594 
>> 87380  16384  16384    10.02      13796.31   99.90    99.90    0.593   0.593 
>> 87380  16384  16384    10.01      13801.97   99.90    99.90    0.593   0.593 
>>
>>netperf -C -c -- -s 1024
>> 87380   2048   2048    10.02         0.43   -0.04    -0.04    -7.105  -7.377
>> 87380   2048   2048    10.02         0.43   -0.01    -0.01    -2.337  -2.620
>> 87380   2048   2048    10.02         0.43   -0.03    -0.03    -5.683  -5.940
>> 87380   2048   2048    10.02         0.43   -0.05    -0.05    -9.373  -9.625
>> 87380   2048   2048    10.02         0.43   -0.05    -0.05    -9.373  -9.625

Hmm, those CPU numbers don't look right.  I guess there must still be 
some holes in the procstat CPU method code in netperf :(


