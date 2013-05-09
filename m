From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Regression: too many packets with incorrect checksum
Date: Thu, 09 May 2013 09:25:31 -0700
Message-ID: <518BCDFB.4090004@hp.com>
References: <1368013888.3115.9.camel@cr0> <1368088578.12413.4.camel@cr0> <1368091063.12413.9.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:28964 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab3EIQZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 12:25:33 -0400
In-Reply-To: <1368091063.12413.9.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2013 02:17 AM, Cong Wang wrote:
> On Thu, 2013-05-09 at 16:36 +0800, Cong Wang wrote:
>>
>> Running another RHEL6 KVM guest, it doesn't have this problem, so it is
>> not related with KVM environment.
>
> I thought it might be due to tcpdump receives a packet which is
> checksummed partially while the wire receives a correct one, but netperf
> shows that is wrong, apparently it hurts performance:
>
> With latest -net:
>
> ~% netperf -4 -H 192.168.122.74
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.122.74 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>
>   87380  16384  16384    10.20     105.19

That the test ran 200 milliseconds "long" (in a LAN environment and 
compared to the other kernel) is another clue that things were not 
entirely well.  I suspect that were you to have netperf emit 
local_transport_retrans:

netperf -4 -H 192.168.122.74 -- -o 
throughput,elapsed_time,local_transport_retrans

you would see a non-trivial number of retransmissions on the connection. 
  You've no doubt already seen that in netstat -s, but the 
per-connection stuff netperf can emit can be helpful when there are 
other things going-on on the system at the same time.

happy benchmarking,

rick ones

>
>
> With a RHEL6 kernel:
>
> ~% netperf -4 -H 192.168.122.101
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.122.101 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>
>   87380  16384  16384    10.00    5528.64
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
