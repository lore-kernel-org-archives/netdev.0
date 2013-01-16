From: Alexey Perevalov <a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH v3] cgroup: net_cls: traffic counter based on
 classification control cgroup
Date: Wed, 16 Jan 2013 19:48:30 +0400
Message-ID: <50F6CBCE.8030803@samsung.com>
References: <20130115133351.GA8633@aperevalov>
 <1358262309.8744.5760.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1358262309.8744.5760.camel@edumazet-glaptop>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Eric

On 01/15/2013 07:05 PM, Eric Dumazet wrote:
> On Tue, 2013-01-15 at 17:33 +0400, Alexey Perevalov wrote:
>> Hello
>>
>> I would like to represent next version of patch I sent before
>> cgroup: "net_cls: traffic counter based on classification control cgroup"
>>
>> The main idea is the same as was. It keeping counter in control groups, but now uses atomic instead of resource_counters.
>>
>> Signed-off-by: Alexey Perevalov<a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
>> ---
>>   include/net/cls_cgroup.h         |  200 ++++++++++++++++++++++++++++++++++----
>>   include/net/cls_counter_holder.h |   26 +++++
>>   init/Kconfig                     |   25 +++++
>>   kernel/cgroup.c                  |    2 +
>>   kernel/res_counter.c             |    4 +
>>   net/core/dev.c                   |    6 ++
>>   net/ipv4/tcp.c                   |   27 ++++-
>>   net/ipv4/udp.c                   |    6 ++
>>   net/sched/Kconfig                |   11 ---
>>   net/sched/Makefile               |    1 +
>>   net/sched/cls_cgroup.c           |  194 +++++++++++++++++++++++++++++++++++-
>>   net/sched/cls_counter_holder.c   |  144 +++++++++++++++++++++++++++
>>   12 files changed, 611 insertions(+), 35 deletions(-)
>>   create mode 100644 include/net/cls_counter_holder.h
>>   create mode 100644 net/sched/cls_counter_holder.c
> Sorry, there are too many issues with this patch and I have not
> a lot of time to review it.
>
> 0) No changelog or documentation
Do you expect documentation in Documentation/cgroups/.
For example I'll create new file net_cls.txt
> 1) There is no way you need to add kludges in tcp and udp for this
> accounting. Retransmitted packets should not be ignored for example.
Retransmitted incoming packets will be ignored - right.
But counting on the 3rd layer of network stack (in netfilter) is 
expensive, we should twice resolve destination process.

> 2) Ugly #ifdef in c files. Don't do that please.
>
> 3) No check of kmalloc() returns (can be NULL)
>
This issues I'll fix.

>


-- 
Best regards,
Alexey Perevalov
