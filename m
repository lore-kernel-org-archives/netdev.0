From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Tue, 02 Jul 2013 14:13:42 -0700
Message-ID: <1372799622.4979.22.camel@edumazet-glaptop>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Fernando Soto <fernando.soto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:52004 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510Ab3GBVNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 17:13:43 -0400
Received: by mail-pb0-f44.google.com with SMTP id uo1so6566359pbc.3
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 14:13:43 -0700 (PDT)
In-Reply-To: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-02 at 17:05 -0400, Fernando Soto wrote:
> Please CC me. I am not subscribed to the list.
> 
> While running iperf network throughput tests between two Linux VMs
> with kernel 3.5.4 in a Hyper-V environment (Host: Win 2K8 R2 P1), I
> consistently run into this kernel warning after 1 or 2 days:
> 
> Jun 29 14:45:44 new kernel: [158511.461245] ------------[ cut here ]------------
> Jun 29 14:45:44 new kernel: [158511.461422] WARNING: at
> net/core/dst.c:274 dst_release+0x2d/0x56()
> Jun 29 14:45:44 new kernel: [158511.461667] Hardware name: Virtual Machine
> Jun 29 14:45:44 new kernel: [158511.462020] Modules linked in: drbd
> lru_cache psmouse crc32c_intel i2c_piix4 microcode hv_utils processor
> cn thermal_sys evdev i2c_core button hv_netvsc hv_storvsc hv_vmbus
> floppy sr_mod cdrom [last
> 
> unloaded: scsi_wait_scan]
> Jun 29 14:45:44 new kernel: [158511.465332] Pid: 2611, comm: iperf Not
> tainted 3.5.4-amd64 #1
> Jun 29 14:45:44 new kernel: [158511.465461] Call Trace:
> Jun 29 14:45:44 new kernel: [158511.465627]  [<ffffffff8103602c>] ?
> warn_slowpath_common+0x76/0x8a
> Jun 29 14:45:44 new kernel: [158511.465834]  [<ffffffff8147de3b>] ?
> dst_release+0x2d/0x56
> Jun 29 14:45:44 new kernel: [158511.466160]  [<ffffffff8146e068>] ?
> skb_release_head_state+0x1e/0xe3
> Jun 29 14:45:44 new kernel: [158511.466339]  [<ffffffff8146df19>] ?
> __kfree_skb+0x9/0x77
> Jun 29 14:45:44 new kernel: [158511.466529]  [<ffffffff814a9a9e>] ?
> tcp_recvmsg+0x6e3/0x96a
> Jun 29 14:45:44 new kernel: [158511.466850]  [<ffffffff814c3695>] ?
> inet_recvmsg+0x5a/0x6e
> Jun 29 14:45:44 new kernel: [158511.467632]  [<ffffffff81465832>] ?
> __sock_recvmsg_nosec+0x29/0x69
> Jun 29 14:45:44 new kernel: [158511.467805]  [<ffffffff81466c65>] ?
> sock_recvmsg+0xc8/0xe8
> Jun 29 14:45:44 new kernel: [158511.467907]  [<ffffffff810bd822>] ?
> pagevec_lookup+0x1c/0x1c
> Jun 29 14:45:44 new kernel: [158511.468004]  [<ffffffff810ba013>] ?
> __free_one_page+0x1cb/0x24b
> Jun 29 14:45:44 new kernel: [158511.468101]  [<ffffffff814b085c>] ?
> tcp_rcv_established+0x479/0x5b0
> Jun 29 14:45:44 new kernel: [158511.468196]  [<ffffffff814b085c>] ?
> tcp_rcv_established+0x479/0x5b0
> Jun 29 14:45:44 new kernel: [158511.468294]  [<ffffffff810ec000>] ?
> fget_light+0x63/0x74
> Jun 29 14:45:44 new kernel: [158511.468408]  [<ffffffff81466df1>] ?
> sockfd_lookup_light+0x17/0x4c
> Jun 29 14:45:44 new kernel: [158511.468505]  [<ffffffff814687c4>] ?
> sys_recvfrom+0xc1/0x123
> Jun 29 14:45:44 new kernel: [158511.468599]  [<ffffffff8101989b>] ?
> read_hv_clock+0x13/0x1c
> Jun 29 14:45:44 new kernel: [158511.468704]  [<ffffffff8106b762>] ?
> timekeeping_get_ns+0xd/0x2a
> Jun 29 14:45:44 new kernel: [158511.468801]  [<ffffffff8106bb16>] ?
> getnstimeofday+0x4d/0x7e
> Jun 29 14:45:44 new kernel: [158511.468906]  [<ffffffff8106bb76>] ?
> do_gettimeofday+0x10/0x30
> Jun 29 14:45:44 new kernel: [158511.469007]  [<ffffffff8105922a>] ?
> should_resched+0x5/0x23
> Jun 29 14:45:44 new kernel: [158511.469116]  [<ffffffff81546783>] ?
> _cond_resched+0x6/0x1a
> Jun 29 14:45:44 new kernel: [158511.469216]  [<ffffffff8154d1fd>] ?
> system_call_fastpath+0x1a/0x1f
> Jun 29 14:45:44 new kernel: [158511.469307] ---[ end trace 1f424b332c392ece ]---
> Jun 29 14:45:44 new kernel: [158511.469516] ------------[ cut here ]------------
> 
> 
> Iperf arguments:
> server VM
> # iperf -s -i 5
> 
> client VM:
> # iperf -c 172.31.248.141 -d -t 1000000 -i 5 -r
> 
> The same problem can't be reproduced on an ESX environment.
> 
> Any help is appreciated.
> 
> Thanks,
> Fernando Soto

Make sure you have following fix : 

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=093162553c33e9479283e107b4431378271c735d
