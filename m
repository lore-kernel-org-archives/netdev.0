From: Joe Jin <joe.jin@oracle.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Sat, 29 Jun 2013 07:36:57 +0800
Message-ID: <51CE1E19.3020108@oracle.com>
References: <51CBAA48.3080802@oracle.com>  <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>  <1372402340.3301.229.camel@edumazet-glaptop> <1372412262.3301.251.camel@edumazet-glaptop>
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
In-Reply-To: <1372412262.3301.251.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

The patch not fix the issue and panic as same as early I posted:
> BUG: unable to handle kernel paging request at ffff88006d9e8d48
> IP: [<ffffffff812605bb>] memcpy+0xb/0x120
> PGD 1798067 PUD 1fd2067 PMD 213f067 PTE 0
> Oops: 0000 [#1] SMP 
> CPU 7 
> Modules linked in: dm_nfs tun nfs fscache auth_rpcgss nfs_acl xen_blkback xen_netback xen_gntdev xen_evtchn lockd sunrpc bridge stp llc bonding be2iscsi iscsi_boot_sysfs ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp bnx2i cnic uio ipv6 cxgb3i libcxgbi cxgb3 mdio dm_round_robin dm_multipath libiscsi_tcp libiscsi scsi_transport_iscsi xenfs xen_privcmd video sbs sbshc acpi_memhotplug acpi_ipmi ipmi_msghandler parport_pc lp parport ixgbe dca sr_mod cdrom bnx2 radeon ttm drm_kms_helper drm snd_seq_dummy i2c_algo_bit i2c_core snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss serio_raw snd_pcm snd_timer snd soundcore snd_page_alloc iTCO_wdt pcspkr iTCO_vendor_support pata_acpi dcdbas i5k_amb ata_generic hwmon floppy ghes i5000_edac edac_core he
 d dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod usb_storage lpfc scsi_transport_fc scsi_tgt ata_piix sg shpchp mptsas mptscsih mptbase scsi_transport_sas sd_mod crc_t10dif ext3!
  jbd mbcac
he
>
>
> Pid: 0, comm: swapper Tainted: G        W   2.6.39-300.32.1.el5uek #1 Dell Inc. PowerEdge 2950/0DP246
> RIP: e030:[<ffffffff812605bb>]  [<ffffffff812605bb>] memcpy+0xb/0x120
> RSP: e02b:ffff8801003c3d58  EFLAGS: 00010246
> RAX: ffff880076b9e280 RBX: ffff8800714d2c00 RCX: 0000000000000057
> RDX: 0000000000000000 RSI: ffff88006d9e8d48 RDI: ffff880076b9e280
> RBP: ffff8801003c3dc0 R08: 00000000000bf723 R09: 0000000000000000
> R10: 0000000000000000 R11: 000000000000000a R12: 0000000000000034
> R13: 0000000000000034 R14: 00000000000002b8 R15: 00000000000005a8
> FS:  00007fc1e852a6e0(0000) GS:ffff8801003c0000(0000) knlGS:0000000000000000
> CS:  e033 DS: 002b ES: 002b CR0: 000000008005003b
> CR2: ffff88006d9e8d48 CR3: 000000006370b000 CR4: 0000000000002660
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process swapper (pid: 0, threadinfo ffff880077ac0000, task ffff880077abe240)
> Stack:
>  ffffffff8142db21 0000000000000000 ffff880076b9e280 ffff8800637097f0
>  000002ec00000000 00000000000002b8 ffff880077ac0000 0000000000000000
>  ffff8800637097f0 ffff880066c9a7c0 00000000fffffdb4 000000000000024c
> Call Trace:
>  <IRQ> 
>  [<ffffffff8142db21>] ? skb_copy_bits+0x1c1/0x2e0
>  [<ffffffff8142f173>] skb_copy+0xf3/0x120
>  [<ffffffff81447fbc>] neigh_timer_handler+0x1ac/0x350
>  [<ffffffff810573fe>] ? account_idle_ticks+0xe/0x10
>  [<ffffffff81447e10>] ? neigh_alloc+0x180/0x180
>  [<ffffffff8107dbaa>] call_timer_fn+0x4a/0x110
>  [<ffffffff81447e10>] ? neigh_alloc+0x180/0x180
>  [<ffffffff8107f82a>] run_timer_softirq+0x13a/0x220
>  [<ffffffff81075c39>] __do_softirq+0xb9/0x1d0
>  [<ffffffff810d9678>] ? handle_percpu_irq+0x48/0x70
>  [<ffffffff81511d3c>] call_softirq+0x1c/0x30
>  [<ffffffff810172e5>] do_softirq+0x65/0xa0
>  [<ffffffff8107656b>] irq_exit+0xab/0xc0
>  [<ffffffff812f97d5>] xen_evtchn_do_upcall+0x35/0x50
>  [<ffffffff81511d8e>] xen_do_hypervisor_callback+0x1e/0x30
>  <EOI> 
>  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>  [<ffffffff8100a0b0>] ? xen_safe_halt+0x10/0x20
>  [<ffffffff8101dfeb>] ? default_idle+0x5b/0x170
>  [<ffffffff81014ac6>] ? cpu_idle+0xc6/0xf0
>  [<ffffffff8100a8c9>] ? xen_irq_enable_direct_reloc+0x4/0x4
>  [<ffffffff814f7bbe>] ? cpu_bringup_and_idle+0xe/0x10
> Code: 01 c6 43 4c 04 19 c0 4c 8b 65 f0 4c 8b 6d f8 83 e0 fc 83 c0 08 88 43 4d 48 8b 5d e8 c9 c3 90 90 48 89 f8 89 d1 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c 8b 4e 08 4c 
> RIP  [<ffffffff812605bb>] memcpy+0xb/0x120
>  RSP <ffff8801003c3d58>
> CR2: ffff88006d9e8d48

Thanks,
Joe
On 06/28/13 17:37, Eric Dumazet wrote:
> OK please try the following patch
> 
> 
> [PATCH] neighbour: fix a race in neigh_destroy()
> 
> There is a race in neighbour code, because neigh_destroy() uses
> skb_queue_purge(&neigh->arp_queue) without holding neighbour lock,
> while other parts of the code assume neighbour rwlock is what
> protects arp_queue
> 
> Convert all skb_queue_purge() calls to the __skb_queue_purge() variant
> 
> Use __skb_queue_head_init() instead of skb_queue_head_init()
> to make clear we do not use arp_queue.lock
> 
> And hold neigh->lock in neigh_destroy() to close the race.
> 
> Reported-by: Joe Jin <joe.jin@oracle.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/neighbour.c |   12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 2569ab2..b7de821 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -231,7 +231,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
>  				   we must kill timers etc. and move
>  				   it to safe state.
>  				 */
> -				skb_queue_purge(&n->arp_queue);
> +				__skb_queue_purge(&n->arp_queue);
>  				n->arp_queue_len_bytes = 0;
>  				n->output = neigh_blackhole;
>  				if (n->nud_state & NUD_VALID)
> @@ -286,7 +286,7 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device
>  	if (!n)
>  		goto out_entries;
>  
> -	skb_queue_head_init(&n->arp_queue);
> +	__skb_queue_head_init(&n->arp_queue);
>  	rwlock_init(&n->lock);
>  	seqlock_init(&n->ha_lock);
>  	n->updated	  = n->used = now;
> @@ -708,7 +708,9 @@ void neigh_destroy(struct neighbour *neigh)
>  	if (neigh_del_timer(neigh))
>  		pr_warn("Impossible event\n");
>  
> -	skb_queue_purge(&neigh->arp_queue);
> +	write_lock_bh(&neigh->lock);
> +	__skb_queue_purge(&neigh->arp_queue);
> +	write_unlock_bh(&neigh->lock);
>  	neigh->arp_queue_len_bytes = 0;
>  
>  	if (dev->netdev_ops->ndo_neigh_destroy)
> @@ -858,7 +860,7 @@ static void neigh_invalidate(struct neighbour *neigh)
>  		neigh->ops->error_report(neigh, skb);
>  		write_lock(&neigh->lock);
>  	}
> -	skb_queue_purge(&neigh->arp_queue);
> +	__skb_queue_purge(&neigh->arp_queue);
>  	neigh->arp_queue_len_bytes = 0;
>  }
>  
> @@ -1210,7 +1212,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>  
>  			write_lock_bh(&neigh->lock);
>  		}
> -		skb_queue_purge(&neigh->arp_queue);
> +		__skb_queue_purge(&neigh->arp_queue);
>  		neigh->arp_queue_len_bytes = 0;
>  	}
>  out:
> 
> 


-- 
Oracle <http://www.oracle.com>
Joe Jin | Software Development Senior Manager | +8610.6106.5624
ORACLE | Linux and Virtualization
No. 24 Zhongguancun Software Park, Haidian District | 100193 Beijing 
