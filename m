From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 15:03:20 -0800
Message-ID: <424C81B8.6090709@us.ibm.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net>	<1112303431.1073.67.camel@jzny.localdomain> <424C6A98.1070509@hp.com> <1112305084.1073.94.camel@jzny.localdomain> <424C7CDC.8050801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <424C7CDC.8050801@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:

>> Take the following scenario in non-NAPI. -packet 1 arrives -interupt 
>> happens, NIC bound to CPU0
>> - in the meantime packets 2,3 arrive
>> - 3 packets put on queue for CPU0
>> - interupt processing done
>>
>> - packet 4 arrives, interupt, CPU1 is bound to NIC
>> - in the meantime packets 5,6 arrive
>> - CPU1 backlog queue used.
>> - interupt processing done
>>
>> Assume CPU0 is overloaded with other systenm work and CPU1 rx processing
>> kicks in first ... TCP sees packet 4, 5, 6 before 1, 2, 3 ..
> 
> 
> I "never" see that because I always bind a NIC to a specific CPU :)  
> Just about every networking-intensive benchmark report I've seen has 
> done the same.

Just a reminder that the networking-benchmark world and
the real networking deployment world have a less than desirable
intersection (which I know you know only too well, Rick ;)).
How often do people use affinity? How often do they really tune
the system for their workloads? How often do they turn off things
like SACK etc? Not very often in the real world. Designing OSs to
do better at benchmarks is a different proposition than designing
OSs to do well in the real world.

>> Note Linux is quiet resilient to reordering compared to other OSes (as
>> you may know) but avoiding this is a better approach - hence my
>> suggestion to use NAPI when you want to do serious TCP.

The real killer for TCP is triggering fast retransmit
unnecessarily - and while we have some reordering detection
and safeguards for that - for other situations like apps
running over UDP and being unable to cope with reordering
(yes, there are dunderheads like that) there is not much
you can do. It does help them to avoid the reordering to
begin with.

thanks,
Nivedita
