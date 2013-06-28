From: Joe Jin <joe.jin@oracle.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Fri, 28 Jun 2013 12:17:43 +0800
Message-ID: <51CD0E67.4000008@oracle.com>
References: <51CBAA48.3080802@oracle.com> <1372311118.3301.214.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zheng.x.li@oracle.com" <zheng.x.li@oracle.com>,
	Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372311118.3301.214.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Find a similar issue  http://www.gossamer-threads.com/lists/xen/devel/265611
So copied to Xen developer as well.

On 06/27/13 13:31, Eric Dumazet wrote:
> On Thu, 2013-06-27 at 10:58 +0800, Joe Jin wrote:
>> Hi,
>>
>> When we do fail over test with iscsi + multipath by reset the switches
>> on OVM(2.6.39) we hit the panic:
>>
>> BUG: unable to handle kernel paging request at ffff88006d9e8d48
>> IP: [<ffffffff812605bb>] memcpy+0xb/0x120
>> PGD 1798067 PUD 1fd2067 PMD 213f067 PTE 0
>> Oops: 0000 [#1] SMP 
>> CPU 7 
>> Modules linked in: dm_nfs tun nfs fscache auth_rpcgss nfs_acl xen_blkback xen_netback xen_gntdev xen_evtchn lockd sunrpc bridge stp llc bonding be2iscsi iscsi_boot_sysfs ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp bnx2i cnic uio ipv6 cxgb3i libcxgbi cxgb3 mdio dm_round_robin dm_multipath libiscsi_tcp libiscsi scsi_transport_iscsi xenfs xen_privcmd video sbs sbshc acpi_memhotplug acpi_ipmi ipmi_msghandler parport_pc lp parport ixgbe dca sr_mod cdrom bnx2 radeon ttm drm_kms_helper drm snd_seq_dummy i2c_algo_bit i2c_core snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss serio_raw snd_pcm snd_timer snd soundcore snd_page_alloc iTCO_wdt pcspkr iTCO_vendor_support pata_acpi dcdbas i5k_amb ata_generic hwmon floppy ghes i5000_edac edac_core h
 ed dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod usb_storage lpfc scsi_transport_fc scsi_tgt ata_piix sg shpchp mptsas mptscsih mptbase scsi_transport_sas sd_mod crc_t10dif ext!
 3!
>   j!
>>  bd mbcache
>>
>>
>> Pid: 0, comm: swapper Tainted: G        W   2.6.39-300.32.1.el5uek #1 Dell Inc. PowerEdge 2950/0DP246
>> RIP: e030:[<ffffffff812605bb>]  [<ffffffff812605bb>] memcpy+0xb/0x120
>> RSP: e02b:ffff8801003c3d58  EFLAGS: 00010246
>> RAX: ffff880076b9e280 RBX: ffff8800714d2c00 RCX: 0000000000000057
>> RDX: 0000000000000000 RSI: ffff88006d9e8d48 RDI: ffff880076b9e280
>> RBP: ffff8801003c3dc0 R08: 00000000000bf723 R09: 0000000000000000
>> R10: 0000000000000000 R11: 000000000000000a R12: 0000000000000034
>> R13: 0000000000000034 R14: 00000000000002b8 R15: 00000000000005a8
>> FS:  00007fc1e852a6e0(0000) GS:ffff8801003c0000(0000) knlGS:0000000000000000
>> CS:  e033 DS: 002b ES: 002b CR0: 000000008005003b
>> CR2: ffff88006d9e8d48 CR3: 000000006370b000 CR4: 0000000000002660
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process swapper (pid: 0, threadinfo ffff880077ac0000, task ffff880077abe240)
>> Stack:
>>  ffffffff8142db21 0000000000000000 ffff880076b9e280 ffff8800637097f0
>>  000002ec00000000 00000000000002b8 ffff880077ac0000 0000000000000000
>>  ffff8800637097f0 ffff880066c9a7c0 00000000fffffdb4 000000000000024c
>> Call Trace:
>>  <IRQ> 
>>  [<ffffffff8142db21>] ? skb_copy_bits+0x1c1/0x2e0
>>  [<ffffffff8142f173>] skb_copy+0xf3/0x120
>>  [<ffffffff81447fbc>] neigh_timer_handler+0x1ac/0x350
>>  [<ffffffff810573fe>] ? account_idle_ticks+0xe/0x10
>>  [<ffffffff81447e10>] ? neigh_alloc+0x180/0x180
>>  [<ffffffff8107dbaa>] call_timer_fn+0x4a/0x110
>>  [<ffffffff81447e10>] ? neigh_alloc+0x180/0x180
>>  [<ffffffff8107f82a>] run_timer_softirq+0x13a/0x220
>>  [<ffffffff81075c39>] __do_softirq+0xb9/0x1d0
>>  [<ffffffff810d9678>] ? handle_percpu_irq+0x48/0x70
>>  [<ffffffff81511d3c>] call_softirq+0x1c/0x30
>>  [<ffffffff810172e5>] do_softirq+0x65/0xa0
>>  [<ffffffff8107656b>] irq_exit+0xab/0xc0
>>  [<ffffffff812f97d5>] xen_evtchn_do_upcall+0x35/0x50
>>  [<ffffffff81511d8e>] xen_do_hypervisor_callback+0x1e/0x30
>>  <EOI> 
>>  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>>  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>>  [<ffffffff8100a0b0>] ? xen_safe_halt+0x10/0x20
>>  [<ffffffff8101dfeb>] ? default_idle+0x5b/0x170
>>  [<ffffffff81014ac6>] ? cpu_idle+0xc6/0xf0
>>  [<ffffffff8100a8c9>] ? xen_irq_enable_direct_reloc+0x4/0x4
>>  [<ffffffff814f7bbe>] ? cpu_bringup_and_idle+0xe/0x10
>> Code: 01 c6 43 4c 04 19 c0 4c 8b 65 f0 4c 8b 6d f8 83 e0 fc 83 c0 08 88 43 4d 48 8b 5d e8 c9 c3 90 90 48 89 f8 89 d1 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c 8b 4e 08 4c 
>> RIP  [<ffffffff812605bb>] memcpy+0xb/0x120
>>  RSP <ffff8801003c3d58>
>> CR2: ffff88006d9e8d48
>>
>> Reviewed vmcore I found the skb->users is 1 at the moment, checked network neighbour 
>> history I found skb_get() be replaced by skb_copy by commit 7e36763b2c:
>>
>> commit 7e36763b2c204d59de4e88087f84a2c0c8421f25                               
>> Author: Frank Blaschka <frank.blaschka@de.ibm.com>                            
>> Date:   Mon Mar 3 12:16:04 2008 -0800
>>
>>     [NET]: Fix race in generic address resolution.                            
>>         
>>     neigh_update sends skb from neigh->arp_queue while neigh_timer_handler    
>>     has increased skbs refcount and calls solicit with the                    
>>     skb. neigh_timer_handler should not increase skbs refcount but make a     
>>     copy of the skb and do solicit with the copy.                             
>>     
>>     Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>                 
>>     Signed-off-by: David S. Miller <davem@davemloft.net>                      
>>
>> So can you please give some details of the race? per vmcore seems like the skb data
>> be freed, I suspected skb_get() lost at somewhere?
>> I reverted above commit the panic not occurred during our testing.
>>
>> Any input will appreciate!
> 
> Well, fact is that your crash is happening in skb_copy().
> 
> Frank patch is OK. I suspect using skb_clone() would work too,
> so if these skb were fclone ready, chance of an GFP_ATOMIC allocation
> error would be smaller.
> 
> So something is providing a wrong skb at the very beginning.
> 
> You could try to do a early skb_copy to catch the bug and see in the
> stack trace what produced this buggy skb.
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 5c56b21..a7a51fd 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1010,6 +1010,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>  				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
>  			}
>  			skb_dst_force(skb);
> +			kfree_skb(skb_copy(skb, GFP_ATOMIC));
>  			__skb_queue_tail(&neigh->arp_queue, skb);
>  			neigh->arp_queue_len_bytes += skb->truesize;
>  		}
> 
> 

BUG: unable to handle kernel paging request at ffff8800488db8dc
IP: [<ffffffff812605bb>] memcpy+0xb/0x120
PGD 1796067 PUD 20e5067 PMD 212a067 PTE 0
Oops: 0000 [#1] SMP 
CPU 13 
Modules linked in: ocfs2 jbd2 xen_blkback xen_netback xen_gntdev xen_evtchn netconsole i2c_dev i2c_core ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue configfs lockd sunrpc dm_round_robin dm_multipath bridge stp llc bonding be2iscsi iscsi_boot_sysfs iscsi_tcp bnx2i cnic uio ipv6 cxgb3i libcxgbi cxgb3 mdio libiscsi_tcp libiscsi scsi_transport_iscsi xenfs xen_privcmd video sbs sbshc hed acpi_memhotplug acpi_ipmi ipmi_msghandler parport_pc lp parport serio_raw ixgbe hpilo tg3 hpwdt dca snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd iTCO_wdt iTCO_vendor_support soundcore snd_page_alloc pcspkr pata_acpi ata_generic dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod usb_storage ata_piix sg shpc
 hp hpsa cciss sd_mod crc_t10dif ext3 jbd mbcache

Pid: 0, comm: swapper Not tainted 2.6.39-300.32.1.el5uek.bug16929255v5 #1 HP ProLiant DL360p Gen8
RIP: e030:[<ffffffff812605bb>]  [<ffffffff812605bb>] memcpy+0xb/0x120
RSP: e02b:ffff88005a9a3b68  EFLAGS: 00010202
RAX: ffff8800200f0280 RBX: 0000000000000724 RCX: 00000000000000e4
RDX: 0000000000000004 RSI: ffff8800488db8dc RDI: ffff8800200f0280
RBP: ffff88005a9a3bd0 R08: 0000000000000004 R09: ffff880052824980
R10: 0000000000000000 R11: 0000000000015048 R12: 0000000000000034
R13: 0000000000000034 R14: 00000000000022f4 R15: ffff880021208ab0
FS:  00007fe8737c96e0(0000) GS:ffff88005a9a0000(0000) knlGS:0000000000000000
CS:  e033 DS: 002b ES: 002b CR0: 000000008005003b
CR2: ffff8800488db8dc CR3: 000000004fb38000 CR4: 0000000000002660
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff880054d36000, task ffff880054d343c0)
Stack:
 ffffffff8142dac7 0000000000000000 00000000ffffffff ffff8800200f0280
 0000075800000000 0000000000000724 ffff880054d36000 0000000000000000
 00000000fffffdb4 ffff880052824980 ffff880021208ab0 000000000000024c
Call Trace:
 <IRQ> 
 [<ffffffff8142dac7>] ? skb_copy_bits+0x167/0x290
 [<ffffffff8142f0b5>] skb_copy+0x85/0xb0
 [<ffffffff8144864d>] __neigh_event_send+0x18d/0x200
 [<ffffffff81449a42>] neigh_resolve_output+0x162/0x1b0
 [<ffffffff81477046>] ip_finish_output+0x146/0x320
 [<ffffffff814754a5>] ip_output+0x85/0xd0
 [<ffffffff814758d9>] ip_local_out+0x29/0x30
 [<ffffffff814761e0>] ip_queue_xmit+0x1c0/0x3d0
 [<ffffffff8148d3ef>] tcp_transmit_skb+0x40f/0x520
 [<ffffffff8148e5ff>] tcp_retransmit_skb+0x16f/0x2e0
 [<ffffffff814908c0>] ? tcp_retransmit_timer+0x4a0/0x4a0
 [<ffffffff814905ad>] tcp_retransmit_timer+0x18d/0x4a0
 [<ffffffff814908c0>] ? tcp_retransmit_timer+0x4a0/0x4a0
 [<ffffffff81490994>] tcp_write_timer+0xd4/0x100
 [<ffffffff8107dbaa>] call_timer_fn+0x4a/0x110
 [<ffffffff814908c0>] ? tcp_retransmit_timer+0x4a0/0x4a0
 [<ffffffff8107f82a>] run_timer_softirq+0x13a/0x220
 [<ffffffff81075c39>] __do_softirq+0xb9/0x1d0
 [<ffffffff810d9678>] ? handle_percpu_irq+0x48/0x70
 [<ffffffff81511b7c>] call_softirq+0x1c/0x30
 [<ffffffff810172e5>] do_softirq+0x65/0xa0
 [<ffffffff8107656b>] irq_exit+0xab/0xc0
 [<ffffffff812f97d5>] xen_evtchn_do_upcall+0x35/0x50
 [<ffffffff81511bce>] xen_do_hypervisor_callback+0x1e/0x30
 <EOI> 
 [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
 [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
 [<ffffffff8100a0d0>] ? xen_safe_halt+0x10/0x20
 [<ffffffff8101dfeb>] ? default_idle+0x5b/0x170
 [<ffffffff81014ac6>] ? cpu_idle+0xc6/0xf0
 [<ffffffff8100a8e9>] ? xen_irq_enable_direct_reloc+0x4/0x4
 [<ffffffff814f7a2e>] ? cpu_bringup_and_idle+0xe/0x10
Code: 01 c6 43 4c 04 19 c0 4c 8b 65 f0 4c 8b 6d f8 83 e0 fc 83 c0 08 88 43 4d 48 8b 5d e8 c9 c3 90 90 48 89 f8 89 d1 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c 8b 4e 08 4c 
RIP  [<ffffffff812605bb>] memcpy+0xb/0x120


Per vmcore, the socket info as below:
------------------------------------------------------------------------------
<struct tcp_sock 0xffff88004d344e00>            TCP
tcp   10.1.1.11:42147            10.1.1.21:3260              FIN_WAIT1
        windows: rcv=122124, snd=65535  advmss=8948 rcv_ws=1 snd_ws=0
        nonagle=1 sack_ok=0 tstamp_ok=1
        rmem_alloc=0, wmem_alloc=10229
        rx_queue=0, tx_queue=149765
        rcvbuf=262142, sndbuf=262142
        rcv_tstamp=51.4 s, lsndtime=0.0 s  ago
    -- Retransmissions --
       retransmits=7, ca_state=TCP_CA_Disorder
------------------------------------------------------------------------------

When sock status move to FIN_WAIT1, will it cleanup all skb or no?

Thanks,
Joe
