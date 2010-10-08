From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 17:53:28 +0200
Message-ID: <4CAF3E78.8030202@free.fr>
References: <201010071048.12817.hans.schillstrom@ericsson.com> <4CAEFE2C.3010007@free.fr> <201010081353.28056.hans.schillstrom@ericsson.com> <201010081428.37639.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:42308 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758700Ab0JHPxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 11:53:34 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o98FrWZZ022100
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 15:53:33 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o98FrXfX3592308
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 16:53:33 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o98FrWmC020294
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 16:53:32 +0100
In-Reply-To: <201010081428.37639.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2010 02:28 PM, Hans Schillstrom wrote:
> Hi Eric,
> Any advice how to trace this down ?
> This rollback_registered_many() seems to have on the lists before...
> All IPv4 and IPv6 tunnels causes this crash, all you have to do is load the tunnel module(s)
> enter a new ns and exit from it.
>
> Have not tested any more devices than tunnels,
> I did an "ip link delete" on my macvlans before exiting the ns.
>    

Ah ! I succeed to reproduce it.
It does not appear immediately in fact.

I am trying to simplify the configuration but I am falling in the bug I 
talked about in the previous email.

> snip
>    
>>   # ------------[ cut here ]------------
>> WARNING: at /home/hans/evip/kvm/net-next-2.6/kernel/sysctl.c:1953 unregister_sysctl_table+0xc7/0xf9()
>> Hardware name: Bochs
>> Modules linked in: macvlan ip6_tunnel tunnel6 pcnet32 tg3 libphy
>> Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc3 #2
>> Call Trace:
>>   [<ffffffff8103e281>] warn_slowpath_common+0x85/0x9d
>>   [<ffffffff8103e2b3>] warn_slowpath_null+0x1a/0x1c
>>   [<ffffffff81045e64>] unregister_sysctl_table+0xc7/0xf9
>>   [<ffffffff812c86a5>] neigh_sysctl_unregister+0x27/0x3f
>>   [<ffffffff81340c75>] addrconf_ifdown+0x415/0x45e
>>   [<ffffffff81341705>] addrconf_notify+0x756/0x7fe
>>   [<ffffffff812cacfb>] ? neigh_ifdown+0xc3/0xd4
>>   [<ffffffff81360eb3>] ? ip6mr_device_event+0x8d/0x9e
>>   [<ffffffff8105eddb>] notifier_call_chain+0x37/0x63
>>   [<ffffffff8105ee8b>] raw_notifier_call_chain+0x14/0x16
>>   [<ffffffff812c15c7>] call_netdevice_notifiers+0x4a/0x4f
>>   [<ffffffff812c1c1b>] rollback_registered_many+0x121/0x208
>>   [<ffffffff812c1d1d>] unregister_netdevice_many+0x1b/0x71
>>   [<ffffffffa0047244>] ip6_tnl_exit_net+0xa4/0xb8 [ip6_tunnel]
>>   [<ffffffff812bc941>] ? cleanup_net+0x0/0x198
>>   [<ffffffff812bc2cf>] ops_exit_list+0x2a/0x5b
>>   [<ffffffff812bca39>] cleanup_net+0xf8/0x198
>>   [<ffffffff810568c7>] process_one_work+0x2a2/0x44d
>>   [<ffffffff81056e35>] worker_thread+0x1db/0x34e
>>   [<ffffffff81056c5a>] ? worker_thread+0x0/0x34e
>>   [<ffffffff8105a030>] kthread+0x82/0x8a
>>   [<ffffffff81003954>] kernel_thread_helper+0x4/0x10
>>   [<ffffffff81059fae>] ? kthread+0x0/0x8a
>>   [<ffffffff81003950>] ? kernel_thread_helper+0x0/0x10
>> ---[ end trace eb3bc950cf9a8748 ]---
>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>      
>
>    

