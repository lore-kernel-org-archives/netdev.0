From: Fernando Soto <fernando.soto@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Thu, 4 Jul 2013 08:21:02 -0400
Message-ID: <CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
	<1372799622.4979.22.camel@edumazet-glaptop>
	<CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35230 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483Ab3GDMVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 08:21:04 -0400
Received: by mail-ob0-f182.google.com with SMTP id va7so1536765obc.41
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 05:21:03 -0700 (PDT)
In-Reply-To: <CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Unfortunately the issue is still reproducible after the patch was
applied. Iperf tests were running for almost 24h when it happened:

Jul  4 02:53:13 new kernel: [88713.797022] ------------[ cut here ]------------
Jul  4 02:53:13 new kernel: [88713.797486] WARNING: at
net/core/dst.c:274 dst_release+0x2d/0x56()
Jul  4 02:53:13 new kernel: [88713.797876] Hardware name: Virtual Machine
Jul  4 02:53:13 new kernel: [88713.798329] Modules linked in: drbd
lru_cache psmouse hv_utils crc32c_intel i2c_piix4 microcode processor
cn i2c_core evdev button thermal_sys hv_storvsc hv_netvsc floppy
sr_mod cdrom hv_vmbus [last unloaded: scsi_wait_scan]
Jul  4 02:53:13 new kernel: [88713.800995] Pid: 2426, comm: iperf Not
tainted 3.5.4-amd64 #1
Jul  4 02:53:13 new kernel: [88713.801196] Call Trace:
Jul  4 02:53:13 new kernel: [88713.801512]  [<ffffffff8103602c>] ?
warn_slowpath_common+0x76/0x8a
Jul  4 02:53:13 new kernel: [88713.801742]  [<ffffffff8147de3b>] ?
dst_release+0x2d/0x56
Jul  4 02:53:13 new kernel: [88713.802008]  [<ffffffff8146e068>] ?
skb_release_head_state+0x1e/0xe3
Jul  4 02:53:13 new kernel: [88713.802200]  [<ffffffff8146df19>] ?
__kfree_skb+0x9/0x77
Jul  4 02:53:13 new kernel: [88713.802290]  [<ffffffff814a9a9e>] ?
tcp_recvmsg+0x6e3/0x96a
Jul  4 02:53:13 new kernel: [88713.802374]  [<ffffffff814c3679>] ?
inet_recvmsg+0x5a/0x6e
Jul  4 02:53:13 new kernel: [88713.802459]  [<ffffffff81465832>] ?
__sock_recvmsg_nosec+0x29/0x69
Jul  4 02:53:13 new kernel: [88713.802542]  [<ffffffff81466c65>] ?
sock_recvmsg+0xc8/0xe8
Jul  4 02:53:13 new kernel: [88713.802627]  [<ffffffff810ba013>] ?
__free_one_page+0x1cb/0x24b
Jul  4 02:53:13 new kernel: [88713.802712]  [<ffffffff814b085c>] ?
tcp_rcv_established+0x479/0x5b0
Jul  4 02:53:13 new kernel: [88713.802795]  [<ffffffff814b085c>] ?
tcp_rcv_established+0x479/0x5b0
Jul  4 02:53:13 new kernel: [88713.802911]  [<ffffffff814a9b83>] ?
tcp_recvmsg+0x7c8/0x96a
Jul  4 02:53:13 new kernel: [88713.803194]  [<ffffffff810ec000>] ?
fget_light+0x63/0x74
Jul  4 02:53:13 new kernel: [88713.803614]  [<ffffffff81466df1>] ?
sockfd_lookup_light+0x17/0x4c
Jul  4 02:53:13 new kernel: [88713.804576]  [<ffffffff814687c4>] ?
sys_recvfrom+0xc1/0x123
Jul  4 02:53:13 new kernel: [88713.804759]  [<ffffffff8101989b>] ?
read_hv_clock+0x13/0x1c
Jul  4 02:53:13 new kernel: [88713.804868]  [<ffffffff8106b762>] ?
timekeeping_get_ns+0xd/0x2a
Jul  4 02:53:13 new kernel: [88713.804971]  [<ffffffff8106bb16>] ?
getnstimeofday+0x4d/0x7e
Jul  4 02:53:13 new kernel: [88713.805074]  [<ffffffff8106bb76>] ?
do_gettimeofday+0x10/0x30
Jul  4 02:53:13 new kernel: [88713.805177]  [<ffffffff8105922a>] ?
should_resched+0x5/0x23
Jul  4 02:53:13 new kernel: [88713.805283]  [<ffffffff815467a3>] ?
_cond_resched+0x6/0x1a
Jul  4 02:53:13 new kernel: [88713.805387]  [<ffffffff8154d1fd>] ?
system_call_fastpath+0x1a/0x1f
Jul  4 02:53:13 new kernel: [88713.805488] ---[ end trace 79a4ed9563ef186f ]---
Jul  4 02:53:13 new kernel: [88713.805603] ------------[ cut here ]------------



On Tue, Jul 2, 2013 at 5:44 PM, Fernando Soto <fernando.soto@gmail.com> wrote:
> Hi Eric,
>
> Thanks! I'll try and let you know.
>
> Fernando
>
> On Tue, Jul 2, 2013 at 5:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2013-07-02 at 17:05 -0400, Fernando Soto wrote:
>>> Please CC me. I am not subscribed to the list.
>>>
>>> While running iperf network throughput tests between two Linux VMs
>>> with kernel 3.5.4 in a Hyper-V environment (Host: Win 2K8 R2 P1), I
>>> consistently run into this kernel warning after 1 or 2 days:
>>>
>>> Jun 29 14:45:44 new kernel: [158511.461245] ------------[ cut here ]------------
>>> Jun 29 14:45:44 new kernel: [158511.461422] WARNING: at
>>> net/core/dst.c:274 dst_release+0x2d/0x56()
>>> Jun 29 14:45:44 new kernel: [158511.461667] Hardware name: Virtual Machine
>>> Jun 29 14:45:44 new kernel: [158511.462020] Modules linked in: drbd
>>> lru_cache psmouse crc32c_intel i2c_piix4 microcode hv_utils processor
>>> cn thermal_sys evdev i2c_core button hv_netvsc hv_storvsc hv_vmbus
>>> floppy sr_mod cdrom [last
>>>
>>> unloaded: scsi_wait_scan]
>>> Jun 29 14:45:44 new kernel: [158511.465332] Pid: 2611, comm: iperf Not
>>> tainted 3.5.4-amd64 #1
>>> Jun 29 14:45:44 new kernel: [158511.465461] Call Trace:
>>> Jun 29 14:45:44 new kernel: [158511.465627]  [<ffffffff8103602c>] ?
>>> warn_slowpath_common+0x76/0x8a
>>> Jun 29 14:45:44 new kernel: [158511.465834]  [<ffffffff8147de3b>] ?
>>> dst_release+0x2d/0x56
>>> Jun 29 14:45:44 new kernel: [158511.466160]  [<ffffffff8146e068>] ?
>>> skb_release_head_state+0x1e/0xe3
>>> Jun 29 14:45:44 new kernel: [158511.466339]  [<ffffffff8146df19>] ?
>>> __kfree_skb+0x9/0x77
>>> Jun 29 14:45:44 new kernel: [158511.466529]  [<ffffffff814a9a9e>] ?
>>> tcp_recvmsg+0x6e3/0x96a
>>> Jun 29 14:45:44 new kernel: [158511.466850]  [<ffffffff814c3695>] ?
>>> inet_recvmsg+0x5a/0x6e
>>> Jun 29 14:45:44 new kernel: [158511.467632]  [<ffffffff81465832>] ?
>>> __sock_recvmsg_nosec+0x29/0x69
>>> Jun 29 14:45:44 new kernel: [158511.467805]  [<ffffffff81466c65>] ?
>>> sock_recvmsg+0xc8/0xe8
>>> Jun 29 14:45:44 new kernel: [158511.467907]  [<ffffffff810bd822>] ?
>>> pagevec_lookup+0x1c/0x1c
>>> Jun 29 14:45:44 new kernel: [158511.468004]  [<ffffffff810ba013>] ?
>>> __free_one_page+0x1cb/0x24b
>>> Jun 29 14:45:44 new kernel: [158511.468101]  [<ffffffff814b085c>] ?
>>> tcp_rcv_established+0x479/0x5b0
>>> Jun 29 14:45:44 new kernel: [158511.468196]  [<ffffffff814b085c>] ?
>>> tcp_rcv_established+0x479/0x5b0
>>> Jun 29 14:45:44 new kernel: [158511.468294]  [<ffffffff810ec000>] ?
>>> fget_light+0x63/0x74
>>> Jun 29 14:45:44 new kernel: [158511.468408]  [<ffffffff81466df1>] ?
>>> sockfd_lookup_light+0x17/0x4c
>>> Jun 29 14:45:44 new kernel: [158511.468505]  [<ffffffff814687c4>] ?
>>> sys_recvfrom+0xc1/0x123
>>> Jun 29 14:45:44 new kernel: [158511.468599]  [<ffffffff8101989b>] ?
>>> read_hv_clock+0x13/0x1c
>>> Jun 29 14:45:44 new kernel: [158511.468704]  [<ffffffff8106b762>] ?
>>> timekeeping_get_ns+0xd/0x2a
>>> Jun 29 14:45:44 new kernel: [158511.468801]  [<ffffffff8106bb16>] ?
>>> getnstimeofday+0x4d/0x7e
>>> Jun 29 14:45:44 new kernel: [158511.468906]  [<ffffffff8106bb76>] ?
>>> do_gettimeofday+0x10/0x30
>>> Jun 29 14:45:44 new kernel: [158511.469007]  [<ffffffff8105922a>] ?
>>> should_resched+0x5/0x23
>>> Jun 29 14:45:44 new kernel: [158511.469116]  [<ffffffff81546783>] ?
>>> _cond_resched+0x6/0x1a
>>> Jun 29 14:45:44 new kernel: [158511.469216]  [<ffffffff8154d1fd>] ?
>>> system_call_fastpath+0x1a/0x1f
>>> Jun 29 14:45:44 new kernel: [158511.469307] ---[ end trace 1f424b332c392ece ]---
>>> Jun 29 14:45:44 new kernel: [158511.469516] ------------[ cut here ]------------
>>>
>>>
>>> Iperf arguments:
>>> server VM
>>> # iperf -s -i 5
>>>
>>> client VM:
>>> # iperf -c 172.31.248.141 -d -t 1000000 -i 5 -r
>>>
>>> The same problem can't be reproduced on an ESX environment.
>>>
>>> Any help is appreciated.
>>>
>>> Thanks,
>>> Fernando Soto
>>
>> Make sure you have following fix :
>>
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=093162553c33e9479283e107b4431378271c735d
>>
>>
