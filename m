From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page
 recycling
Date: Mon, 13 Feb 2017 10:50:43 +0200
Message-ID: <5efe33e3-8009-683b-b913-1b97dce3fac2@gmail.com>
References: <20170209135838.16487-1-edumazet@google.com>
 <9b098a3d-aec0-4085-2cd5-ea3819927071@mellanox.com>
 <b7f2d119-3c84-b911-eeb4-880427299213@mellanox.com>
 <CANn89iJdVbQ2WNK=6pj65J=aBGOn8pXZvpDud_Dy9yFje30mjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36378 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750975AbdBMIus (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 03:50:48 -0500
Received: by mail-wr0-f193.google.com with SMTP id k90so22898480wrc.3
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 00:50:48 -0800 (PST)
In-Reply-To: <CANn89iJdVbQ2WNK=6pj65J=aBGOn8pXZvpDud_Dy9yFje30mjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/02/2017 6:48 PM, Eric Dumazet wrote:
>> Setup 2: PowerPC
>>
>> [10586.623028] Unable to handle kernel paging request for data at address
>> 0x800000251f9001c
>> [10586.623072] Faulting instruction address: 0xc000000000236fa8
>> [10586.623081] Oops: Kernel access of bad area, sig: 11 [#1]
>> [10586.623087] SMP NR_CPUS=2048
>> [10586.623087] NUMA
>> [10586.623093] pSeries
>> [10586.623103] Modules linked in: rdma_ucm ib_ucm rdma_cm iw_cm ib_ipoib
>> ib_cm ib_uverbs ib_umad mlx5_ib mlx5_core mlx4_en ptp pps_core mlx4_ib
>> ib_core mlx4_core devlink netconsole 8021q garp mrp stp llc nfsv3 nfs
>> fscache sg pseries_rng nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables
>> ext4 mbcache jbd2 sd_mod ibmvscsi ibmveth scsi_transport_srp [last unloaded:
>> devlink]
>> [10586.623137] CPU: 8 PID: 30175 Comm: ifconfig Not tainted
>> 4.10.0-rc6-eric_v2 #1
>> [10586.623144] task: c00000000b1e4480 task.stack: c00000000a3cc000
>> [10586.623151] NIP: c000000000236fa8 LR: d000000004f738c4 CTR:
>> c000000000236fa0
>> [10586.623156] REGS: c00000000a3cf360 TRAP: 0380   Not tainted
>> (4.10.0-rc6-eric_v2)
>> [10586.623162] MSR: 800000000280b032 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI>
>> [10586.623167]   CR: 28002048  XER: 20000000
>> [10586.623178] CFAR: d000000004f87ab0 SOFTE: 1
>> [10586.623178] GPR00: d000000004f739d0 c00000000a3cf5e0 c00000000121da00
>> 0800000251f90000
>> [10586.623178] GPR04: 0000000000000000 0000000000010000 0000000000000002
>> 0000000000000000
>> [10586.623178] GPR08: c0000000011a3218 c000000000026320 0800000251f9001c
>> d000000004f87a98
>> [10586.623178] GPR12: c000000000236fa0 c00000000e834800 00003fffd7c08bcc
>> 0000000000000000
>> [10586.623178] GPR16: 0000000000000000 00003fffd7c08bd8 00003fffd7c08c18
>> 00003fffd7c08bd0
>> [10586.623178] GPR20: c0000002b37f1438 c000000275b5b400 c0000002b37f1438
>> 0000000000000046
>> [10586.623178] GPR24: 5deadbeef0000200 c0000002b37e0900 0000000000000000
>> d000000004fd0020
>> [10586.623178] GPR28: c0000002b37f0900 0000000000000000 0000000000000000
>> d000000004fd0020
>> [10586.623223] NIP [c000000000236fa8] .__free_pages+0x8/0x50
>> [10586.623236] LR [d000000004f738c4]
>> .mlx4_en_free_rx_desc.isra.21+0xd4/0x180 [mlx4_en]
>> [10586.623243] Call Trace:
>> [10586.623248] [c00000000a3cf5e0] [c0000002b37ed770] 0xc0000002b37ed770
>> (unreliable)
>> [10586.623260] [c00000000a3cf690] [d000000004f739d0]
>> .mlx4_en_free_rx_buf+0x60/0x130 [mlx4_en]
>> [10586.623274] [c00000000a3cf720] [d000000004f74658]
>> .mlx4_en_deactivate_rx_ring+0x128/0x180 [mlx4_en]
>> [10586.623286] [c00000000a3cf7c0] [d000000004f815c4]
>> .mlx4_en_stop_port+0x614/0x950 [mlx4_en]
>> [10586.623297] [c00000000a3cf8a0] [d000000004f81abc]
>> .mlx4_en_change_mtu+0x1bc/0x210 [mlx4_en]
>> [10586.623307] [c00000000a3cf940] [c000000000736f50]
>> .dev_set_mtu+0x190/0x270
>> [10586.623316] [c00000000a3cf9e0] [c0000000007644c8] .dev_ifsioc+0x348/0x3f0
>> [10586.623323] [c00000000a3cfa80] [c000000000764920] .dev_ioctl+0x3b0/0x880
>> [10586.623331] [c00000000a3cfb70] [c000000000712880]
>> .sock_do_ioctl+0x90/0xb0
>> [10586.623337] [c00000000a3cfc00] [c000000000713380] .sock_ioctl+0x2b0/0x390
>> [10586.623345] [c00000000a3cfca0] [c0000000003059b4]
>> .do_vfs_ioctl+0xc4/0x8b0
>> [10586.623352] [c00000000a3cfd90] [c000000000306264] .SyS_ioctl+0xc4/0xe0
>> [10586.623360] [c00000000a3cfe30] [c00000000000b184] system_call+0x38/0xe0
>> [10586.623367] Instruction dump:
>> [10586.623372] fadf0028 7f1cd92a 4bfffe70 7f43d378 7fe4fb78 7fa5eb78
>> 38c00000 38e00005
>> [10586.623383] 4bffd689 4bfffe6c 7c0004ac 3943001c <7d005028> 3108ffff
>> 7d00512d 40c2fff4
>> [10586.623397] ---[ end trace 97ff7bd173bea34a ]---
>> [10586.623403]
>> [10588.623447] Kernel panic - not syncing: Fatal exception
>
> Yeah, changing MTU seems to be problematic because of the log_rx_info
> trick that you already mentioned.
>
> Can you tell me what was the old MTU and what is the new one ?
MTU is changed from 1500 to 500, with VLAN configured.
>
> Thanks
