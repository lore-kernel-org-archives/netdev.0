From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Initialize unmasked key and uid len
Date: Fri, 6 Feb 2015 10:21:37 -0800
Message-ID: <CALnjE+rQALWbr+a0+d9r0RbD17Z0HYa-esYJjce=AWmXDZdESQ@mail.gmail.com>
References: <1423158984-1674-1-git-send-email-pshelar@nicira.com>
	<1423161437.31870.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Joe Stringer <joestringer@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:55543 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754002AbbBFSVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 13:21:38 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so4556363igb.2
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 10:21:37 -0800 (PST)
In-Reply-To: <1423161437.31870.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 10:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-02-05 at 09:56 -0800, Pravin B Shelar wrote:
>> Flow alloc needs to initialize unmasked key pointer. Otherwise
>> it can crash kernel trying to free random unmasked-key pointer.
>
>> CC: Joe Stringer <joestringer@nicira.com>
>> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>>  net/openvswitch/flow_table.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
>> index 5e57628..d58447d 100644
>> --- a/net/openvswitch/flow_table.c
>> +++ b/net/openvswitch/flow_table.c
>> @@ -85,6 +85,8 @@ struct sw_flow *ovs_flow_alloc(void)
>>
>>       flow->sf_acts = NULL;
>>       flow->mask = NULL;
>> +     flow->id.unmasked_key = NULL;
>> +     flow->id.ufid_len = 0;
>>       flow->stats_last_writer = NUMA_NO_NODE;
>
> At this stage, one has to wonder why not using kmem_cache_zalloc()
> and reduce icache pressure right ?
>
struct flow is still big struct, about 536 bytes. Most of the struct
is still not cleared. I do not want to clear it then initialize it
again. This helps in OVS flow setup performance.

> And please please add :
>
> Fixes: e64457191a259 ("openvswitch: Restructure datapath.c and flow.c")
>
> or whatever commit was the bug origin.
>
ok, I will send updated patch.

> Thanks
>
>
