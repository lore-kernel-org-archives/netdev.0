From: jean-philippe menil <jpmenil@gmail.com>
Subject: Re: BUG: KASAN: use-after-free in free_old_xmit_skbs
Date: Thu, 22 Jun 2017 08:15:58 +0200
Message-ID: <CAOTcU=u_HSMQiwDF3Snv5P8mT-b_Aepeb=Z9gbLd1j=2P+Yy+A@mail.gmail.com>
References: <d2e8cf65-ea3d-7db2-9382-a063daf1168a@gmail.com>
	<20170605050423-mutt-send-email-mst@kernel.org>
	<20170606024211-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2957328232076437393=="
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170606024211-mutt-send-email-mst@kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============2957328232076437393==
Content-Type: multipart/alternative; boundary="001a11498f001909d50552866b18"

--001a11498f001909d50552866b18
Content-Type: text/plain; charset="UTF-8"

2017-06-06 1:52 GMT+02:00 Michael S. Tsirkin <mst@redhat.com>:

> On Mon, Jun 05, 2017 at 05:08:25AM +0300, Michael S. Tsirkin wrote:
> > On Mon, Jun 05, 2017 at 12:48:53AM +0200, Jean-Philippe Menil wrote:
> > > Hi,
> > >
> > > while playing with xdp and ebpf, i'm hitting the following:
> > >
> > > [  309.993136]
> > > ==================================================================
> > > [  309.994735] BUG: KASAN: use-after-free in
> > > free_old_xmit_skbs.isra.29+0x2b7/0x2e0 [virtio_net]
> > > [  309.998396] Read of size 8 at addr ffff88006aa64220 by task sshd/323
> > > [  310.000650]
> > > [  310.002305] CPU: 1 PID: 323 Comm: sshd Not tainted 4.12.0-rc3+ #2
> > > [  310.004018] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS
> > > 1.10.2-20170228_101828-anatol 04/01/2014
> > > [  310.006495] Call Trace:
> > > [  310.007610]  dump_stack+0xb8/0x14c
> > > [  310.008748]  ? _atomic_dec_and_lock+0x174/0x174
> > > [  310.009998]  ? pm_qos_get_value.part.7+0x6/0x6
> > > [  310.011203]  print_address_description+0x6f/0x280
> > > [  310.012416]  kasan_report+0x27a/0x370
> > > [  310.013573]  ? free_old_xmit_skbs.isra.29+0x2b7/0x2e0 [virtio_net]
> > > [  310.014900]  __asan_report_load8_noabort+0x19/0x20
> > > [  310.016136]  free_old_xmit_skbs.isra.29+0x2b7/0x2e0 [virtio_net]
> > > [  310.017467]  ? virtnet_del_vqs+0xe0/0xe0 [virtio_net]
> > > [  310.018759]  ? packet_rcv+0x20d0/0x20d0
> > > [  310.019950]  ? dev_queue_xmit_nit+0x5cd/0xaf0
> > > [  310.021168]  start_xmit+0x1b4/0x1b10 [virtio_net]
> > > [  310.022413]  ? default_device_exit+0x2d0/0x2d0
> > > [  310.023634]  ? virtnet_remove+0xf0/0xf0 [virtio_net]
> > > [  310.024874]  ? update_load_avg+0x1281/0x29f0
> > > [  310.026059]  dev_hard_start_xmit+0x1ea/0x7f0
> > > [  310.027247]  ? validate_xmit_skb_list+0x100/0x100
> > > [  310.028470]  ? validate_xmit_skb+0x7f/0xc10
> > > [  310.029731]  ? netif_skb_features+0x920/0x920
> > > [  310.033469]  ? __skb_tx_hash+0x2f0/0x2f0
> > > [  310.035615]  ? validate_xmit_skb_list+0xa3/0x100
> > > [  310.037782]  sch_direct_xmit+0x2eb/0x7a0
> > > [  310.039842]  ? dev_deactivate_queue.constprop.29+0x230/0x230
> > > [  310.041980]  ? netdev_pick_tx+0x212/0x2b0
> > > [  310.043868]  __dev_queue_xmit+0x12fa/0x20b0
> > > [  310.045564]  ? netdev_pick_tx+0x2b0/0x2b0
> > > [  310.047210]  ? __account_cfs_rq_runtime+0x630/0x630
> > > [  310.048301]  ? update_stack_state+0x402/0x780
> > > [  310.049307]  ? account_entity_enqueue+0x730/0x730
> > > [  310.050322]  ? __rb_erase_color+0x27d0/0x27d0
> > > [  310.051286]  ? update_curr_fair+0x70/0x70
> > > [  310.052206]  ? enqueue_entity+0x2450/0x2450
> > > [  310.053124]  ? entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.054082]  ? dequeue_entity+0x27a/0x1520
> > > [  310.054967]  ? bpf_prog_alloc+0x320/0x320
> > > [  310.055822]  ? yield_to_task_fair+0x110/0x110
> > > [  310.056708]  ? set_next_entity+0x2f2/0xa90
> > > [  310.057574]  ? dequeue_task_fair+0xc09/0x2ec0
> > > [  310.058457]  dev_queue_xmit+0x10/0x20
> > > [  310.059298]  ip_finish_output2+0xacf/0x12a0
> > > [  310.060160]  ? dequeue_entity+0x1520/0x1520
> > > [  310.063410]  ? ip_fragment.constprop.47+0x220/0x220
> > > [  310.065078]  ? ring_buffer_set_clock+0x50/0x50
> > > [  310.066677]  ? __switch_to+0x685/0xda0
> > > [  310.068166]  ? load_balance+0x38f0/0x38f0
> > > [  310.069544]  ? compat_start_thread+0x80/0x80
> > > [  310.070989]  ? trace_find_cmdline+0x60/0x60
> > > [  310.072402]  ? rt_cpu_seq_show+0x2d0/0x2d0
> > > [  310.073579]  ip_finish_output+0x407/0x880
> > > [  310.074441]  ? ip_finish_output+0x407/0x880
> > > [  310.075255]  ? update_stack_state+0x402/0x780
> > > [  310.076076]  ip_output+0x1c0/0x640
> > > [  310.076843]  ? ip_mc_output+0x1350/0x1350
> > > [  310.077642]  ? __sk_dst_check+0x164/0x370
> > > [  310.078441]  ? complete_formation.isra.53+0xa30/0xa30
> > > [  310.079313]  ? __read_once_size_nocheck.constprop.7+0x20/0x20
> > > [  310.080265]  ? sock_prot_inuse_add+0xa0/0xa0
> > > [  310.081097]  ? memcpy+0x45/0x50
> > > [  310.081850]  ? __copy_skb_header+0x1fa/0x280
> > > [  310.082676]  ip_local_out+0x70/0x90
> > > [  310.083448]  ip_queue_xmit+0x8a1/0x22a0
> > > [  310.084236]  ? ip_build_and_send_pkt+0xe80/0xe80
> > > [  310.085079]  ? tcp_v4_md5_lookup+0x13/0x20
> > > [  310.085884]  tcp_transmit_skb+0x187a/0x3e00
> > > [  310.086696]  ? __tcp_select_window+0xaf0/0xaf0
> > > [  310.087524]  ? sock_sendmsg+0xba/0xf0
> > > [  310.088298]  ? __vfs_write+0x4e0/0x960
> > > [  310.089074]  ? vfs_write+0x155/0x4b0
> > > [  310.089838]  ? SyS_write+0xf7/0x240
> > > [  310.090593]  ? do_syscall_64+0x235/0x5b0
> > > [  310.091372]  ? entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.094690]  ? sock_sendmsg+0xba/0xf0
> > > [  310.096133]  ? do_syscall_64+0x235/0x5b0
> > > [  310.097593]  ? entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.099157]  ? tcp_init_tso_segs+0x1e0/0x1e0
> > > [  310.100539]  ? radix_tree_lookup+0xd/0x10
> > > [  310.101894]  ? get_work_pool+0xcd/0x150
> > > [  310.103216]  ? check_flush_dependency+0x330/0x330
> > > [  310.104113]  tcp_write_xmit+0x498/0x52a0
> > > [  310.104905]  ? kasan_unpoison_shadow+0x35/0x50
> > > [  310.105729]  ? kasan_kmalloc+0xad/0xe0
> > > [  310.106505]  ? tcp_transmit_skb+0x3e00/0x3e00
> > > [  310.107331]  ? memset+0x31/0x40
> > > [  310.108070]  ? __check_object_size+0x22e/0x55c
> > > [  310.108895]  ? skb_pull_rcsum+0x2b0/0x2b0
> > > [  310.109690]  ? check_stack_object+0x120/0x120
> > > [  310.110512]  ? tcp_v4_md5_lookup+0x13/0x20
> > > [  310.111315]  __tcp_push_pending_frames+0x8d/0x2a0
> > > [  310.112159]  tcp_push+0x47c/0xbd0
> > > [  310.112912]  ? copy_from_iter_full+0x21e/0xc70
> > > [  310.113747]  ? sock_warn_obsolete_bsdism+0x70/0x70
> > > [  310.114604]  ? tcp_splice_data_recv+0x1c0/0x1c0
> > > [  310.115436]  ? iov_iter_copy_from_user_atomic+0xeb0/0xeb0
> > > [  310.116324]  tcp_sendmsg+0xd6d/0x43f0
> > > [  310.117106]  ? tcp_sendpage+0x2170/0x2170
> > > [  310.117911]  ? set_fd_set.part.1+0x50/0x50
> > > [  310.118718]  ? remove_wait_queue+0x196/0x3b0
> > > [  310.119535]  ? set_fd_set.part.1+0x50/0x50
> > > [  310.120365]  ? add_wait_queue_exclusive+0x290/0x290
> > > [  310.121224]  ? __wake_up+0x44/0x50
> > > [  310.121985]  ? n_tty_read+0x9f9/0x19d0
> > > [  310.122898]  ? __check_object_size+0x22e/0x55c
> > > [  310.125380]  inet_sendmsg+0x111/0x590
> > > [  310.126863]  ? inet_recvmsg+0x5e0/0x5e0
> > > [  310.128348]  ? inet_recvmsg+0x5e0/0x5e0
> > > [  310.129817]  sock_sendmsg+0xba/0xf0
> > > [  310.131110]  sock_write_iter+0x2e4/0x6a0
> > > [  310.132433]  ? core_sys_select+0x47d/0x780
> > > [  310.133779]  ? sock_sendmsg+0xf0/0xf0
> > > [  310.134591]  __vfs_write+0x4e0/0x960
> > > [  310.135351]  ? kvm_clock_get_cycles+0x1e/0x20
> > > [  310.136160]  ? __vfs_read+0x950/0x950
> > > [  310.136931]  ? rw_verify_area+0xbd/0x2b0
> > > [  310.137711]  vfs_write+0x155/0x4b0
> > > [  310.138454]  SyS_write+0xf7/0x240
> > > [  310.139183]  ? SyS_read+0x240/0x240
> > > [  310.139922]  ? SyS_read+0x240/0x240
> > > [  310.140649]  do_syscall_64+0x235/0x5b0
> > > [  310.141390]  ? trace_raw_output_sys_exit+0xf0/0xf0
> > > [  310.142204]  ? syscall_return_slowpath+0x240/0x240
> > > [  310.143018]  ? trace_do_page_fault+0xc4/0x3a0
> > > [  310.143810]  ? prepare_exit_to_usermode+0x124/0x160
> > > [  310.144634]  ? perf_trace_sys_enter+0x1080/0x1080
> > > [  310.145447]  entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.146257] RIP: 0033:0x7f6f868fb070
> > > [  310.146999] RSP: 002b:00007fffed379578 EFLAGS: 00000246 ORIG_RAX:
> > > 0000000000000001
> > > [  310.148507] RAX: ffffffffffffffda RBX: 00000000000002e4 RCX:
> > > 00007f6f868fb070
> > > [  310.149521] RDX: 00000000000002e4 RSI: 000055603b5cfc10 RDI:
> > > 0000000000000003
> > > [  310.150532] RBP: 000055603b5aca60 R08: 0000000000000000 R09:
> > > 0000000000003000
> > > [  310.151530] R10: 0000000000000008 R11: 0000000000000246 R12:
> > > 0000000000000000
> > > [  310.152537] R13: 00007fffed37960f R14: 000055603a832e31 R15:
> > > 0000000000000003
> > > [  310.153578]
> > > [  310.156362] Allocated by task 483:
> > > [  310.157812]  save_stack_trace+0x1b/0x20
> > > [  310.159274]  save_stack+0x43/0xd0
> > > [  310.160663]  kasan_kmalloc+0xad/0xe0
> > > [  310.161943]  __kmalloc+0x105/0x230
> > > [  310.163233]  __vring_new_virtqueue+0xd1/0xee0
> > > [  310.164623]  vring_create_virtqueue+0x2e3/0x5e0
> > > [  310.165536]  setup_vq+0x136/0x620
> > > [  310.166286]  vp_setup_vq+0x13d/0x6d0
> > > [  310.167059]  vp_find_vqs_msix+0x46c/0xb50
> > > [  310.167855]  vp_find_vqs+0x71/0x410
> > > [  310.168641]  vp_modern_find_vqs+0x21/0x140
> > > [  310.169453]  init_vqs+0x957/0x1390 [virtio_net]
> > > [  310.170306]  virtnet_restore_up+0x4a/0x590 [virtio_net]
> > > [  310.171214]  virtnet_xdp+0x89f/0xdf0 [virtio_net]
> > > [  310.172077]  dev_change_xdp_fd+0x1ca/0x420
> > > [  310.172918]  do_setlink+0x2c33/0x3bc0
> > > [  310.173703]  rtnl_setlink+0x245/0x380
> > > [  310.174511]  rtnetlink_rcv_msg+0x530/0x9b0
> > > [  310.175344]  netlink_rcv_skb+0x213/0x450
> > > [  310.176166]  rtnetlink_rcv+0x28/0x30
> > > [  310.176990]  netlink_unicast+0x4a0/0x6c0
> > > [  310.177807]  netlink_sendmsg+0x9ec/0xe50
> > > [  310.178646]  sock_sendmsg+0xba/0xf0
> > > [  310.179435]  SYSC_sendto+0x31d/0x620
> > > [  310.180229]  SyS_sendto+0xe/0x10
> > > [  310.181004]  do_syscall_64+0x235/0x5b0
> > > [  310.181783]  return_from_SYSCALL_64+0x0/0x6a
> > > [  310.182595]
> > > [  310.183217] Freed by task 483:
> > > [  310.183934]  save_stack_trace+0x1b/0x20
> > > [  310.184801]  save_stack+0x43/0xd0
> > > [  310.187187]  kasan_slab_free+0x72/0xc0
> > > [  310.188530]  kfree+0x94/0x1a0
> > > [  310.189797]  vring_del_virtqueue+0x19a/0x430
> > > [  310.191221]  del_vq+0x11c/0x250
> > > [  310.192474]  vp_del_vqs+0x379/0xc30
> > > [  310.193772]  virtnet_del_vqs+0xad/0xe0 [virtio_net]
> > > [  310.195064]  virtnet_xdp+0x836/0xdf0 [virtio_net]
> > > [  310.196231]  dev_change_xdp_fd+0x37c/0x420
> > > [  310.197072]  do_setlink+0x2c33/0x3bc0
> > > [  310.197804]  rtnl_setlink+0x245/0x380
> > > [  310.198530]  rtnetlink_rcv_msg+0x530/0x9b0
> > > [  310.199283]  netlink_rcv_skb+0x213/0x450
> > > [  310.200036]  rtnetlink_rcv+0x28/0x30
> > > [  310.200754]  netlink_unicast+0x4a0/0x6c0
> > > [  310.201496]  netlink_sendmsg+0x9ec/0xe50
> > > [  310.202236]  sock_sendmsg+0xba/0xf0
> > > [  310.202947]  SYSC_sendto+0x31d/0x620
> > > [  310.203660]  SyS_sendto+0xe/0x10
> > > [  310.204340]  do_syscall_64+0x235/0x5b0
> > > [  310.205050]  return_from_SYSCALL_64+0x0/0x6a
> > > [  310.205792]
> > > [  310.206350] The buggy address belongs to the object at
> ffff88006aa64200
> > > [  310.206350]  which belongs to the cache kmalloc-8192 of size 8192
> > > [  310.208149] The buggy address is located 32 bytes inside of
> > > [  310.208149]  8192-byte region [ffff88006aa64200, ffff88006aa66200)
> > > [  310.209929] The buggy address belongs to the page:
> > > [  310.210763] page:ffffea0001aa9800 count:1 mapcount:0 mapping:
> (null)
> > > index:0x0 compound_mapcount: 0
> > > [  310.212499] flags: 0x1ffff8000008100(slab|head)
> > > [  310.213373] raw: 01ffff8000008100 0000000000000000 0000000000000000
> > > 0000000100030003
> > > [  310.214481] raw: dead000000000100 dead000000000200 ffff88006cc02700
> > > 0000000000000000
> > > [  310.215635] page dumped because: kasan: bad access detected
> > > [  310.218989]
> > > [  310.220398] Memory state around the buggy address:
> > > [  310.222141]  ffff88006aa64100: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc
> > > fc fc
> > > [  310.223996]  ffff88006aa64180: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc
> > > fc fc
> > > [  310.225469] >ffff88006aa64200: fb fb fb fb fb fb fb fb fb fb fb fb
> fb fb
> > > fb fb
> > > [  310.227400]                                ^
> > > [  310.228367]  ffff88006aa64280: fb fb fb fb fb fb fb fb fb fb fb fb
> fb fb
> > > fb fb
> > > [  310.229510]  ffff88006aa64300: fb fb fb fb fb fb fb fb fb fb fb fb
> fb fb
> > > fb fb
> > > [  310.230639]
> > > ==================================================================
> > > [  310.231788] Disabling lock debugging due to kernel taint
> > > [  310.233499] kasan: CONFIG_KASAN_INLINE enabled
> > > [  310.236846] kasan: GPF could be caused by NULL-ptr deref or user
> memory
> > > access
> > > [  310.239138] general protection fault: 0000 [#1] SMP KASAN
> > > [  310.240926] Modules linked in: joydev kvm_intel kvm psmouse
> irqbypass
> > > i2c_piix4 qemu_fw_cfg ip_tables x_tables autofs4 serio_raw
> virtio_balloon
> > > pata_acpi virtio_net virtio_blk
> > > [  310.243618] CPU: 0 PID: 352 Comm: sshd Tainted: G    B 4.12.0-rc3+
> #2
> > > [  310.245780] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS
> > > 1.10.2-20170228_101828-anatol 04/01/2014
> > > [  310.249799] task: ffff880066ca8d80 task.stack: ffff880069e40000
> > > [  310.251090] RIP: 0010:free_old_xmit_skbs.isra.29+0x9d/0x2e0
> [virtio_net]
> > > [  310.252403] RSP: 0018:ffff880069e46540 EFLAGS: 00010202
> > > [  310.253631] RAX: 0000000000000000 RBX: 0000000000000000 RCX:
> > > 0000000000000004
> > > [  310.255916] RDX: dffffc0000000000 RSI: 0000000000000008 RDI:
> > > 0000000000000020
> > > [  310.258017] RBP: ffff880069e465e8 R08: ffff880069e45f10 R09:
> > > ffff880066b3c400
> > > [  310.259430] R10: ffff880069e45e98 R11: 1ffff1000cd952f3 R12:
> > > ffff880066b3c400
> > > [  310.260797] R13: ffff880066b3c400 R14: ffff88006afc9156 R15:
> > > ffff88006afc9001
> > > [  310.262139] FS:  00007f3020f26680(0000) GS:ffff88006d000000(0000)
> > > knlGS:0000000000000000
> > > [  310.263564] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [  310.264825] CR2: 00007efed4534010 CR3: 000000006986d000 CR4:
> > > 00000000000006f0
> > > [  310.266178] Call Trace:
> > > [  310.267231]  ? virtnet_del_vqs+0xe0/0xe0 [virtio_net]
> > > [  310.268453]  ? packet_rcv+0x20d0/0x20d0
> > > [  310.269559]  start_xmit+0x1b4/0x1b10 [virtio_net]
> > > [  310.270762]  ? default_device_exit+0x2d0/0x2d0
> > > [  310.271910]  ? virtnet_remove+0xf0/0xf0 [virtio_net]
> > > [  310.273076]  ? update_load_avg+0x1281/0x29f0
> > > [  310.274189]  dev_hard_start_xmit+0x1ea/0x7f0
> > > [  310.275295]  ? validate_xmit_skb_list+0x100/0x100
> > > [  310.276425]  ? validate_xmit_skb+0x7f/0xc10
> > > [  310.277548]  ? rb_insert_color+0x1590/0x1590
> > > [  310.280172]  ? netif_skb_features+0x920/0x920
> > > [  310.281275]  ? __skb_tx_hash+0x2f0/0x2f0
> > > [  310.282362]  ? validate_xmit_skb_list+0xa3/0x100
> > > [  310.283494]  sch_direct_xmit+0x2eb/0x7a0
> > > [  310.284559]  ? dev_deactivate_queue.constprop.29+0x230/0x230
> > > [  310.286448]  ? netdev_pick_tx+0x212/0x2b0
> > > [  310.288251]  ? __account_cfs_rq_runtime+0x630/0x630
> > > [  310.289707]  __dev_queue_xmit+0x12fa/0x20b0
> > > [  310.290788]  ? netdev_pick_tx+0x2b0/0x2b0
> > > [  310.291837]  ? update_curr+0x1ef/0x750
> > > [  310.292826]  ? update_stack_state+0x402/0x780
> > > [  310.293827]  ? account_entity_enqueue+0x730/0x730
> > > [  310.294831]  ? update_stack_state+0x402/0x780
> > > [  310.295818]  ? update_curr_fair+0x70/0x70
> > > [  310.296737]  ? entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.297693]  ? dequeue_entity+0x27a/0x1520
> > > [  310.298591]  ? bpf_prog_alloc+0x320/0x320
> > > [  310.299484]  ? yield_to_task_fair+0x110/0x110
> > > [  310.300385]  ? unwind_dump+0x4e0/0x4e0
> > > [  310.301246]  ? __free_insn_slot+0x600/0x600
> > > [  310.302125]  ? unwind_dump+0x4e0/0x4e0
> > > [  310.302975]  ? dequeue_task_fair+0xc09/0x2ec0
> > > [  310.303883]  dev_queue_xmit+0x10/0x20
> > > [  310.304711]  ip_finish_output2+0xacf/0x12a0
> > > [  310.305558]  ? dequeue_entity+0x1520/0x1520
> > > [  310.306393]  ? ip_fragment.constprop.47+0x220/0x220
> > > [  310.307320]  ? save_stack_trace+0x1b/0x20
> > > [  310.308133]  ? save_stack+0x43/0xd0
> > > [  310.309081]  ? kasan_slab_free+0x72/0xc0
> > > [  310.310614]  ? kfree_skbmem+0xb6/0x1d0
> > > [  310.311406]  ? tcp_ack+0x2730/0x7450
> > > [  310.312167]  ? tcp_rcv_established+0xdbb/0x2db0
> > > [  310.312987]  ? tcp_v4_do_rcv+0x2bb/0x7a0
> > > [  310.313769]  ? __release_sock+0x14a/0x2b0
> > > [  310.314550]  ? release_sock+0xa8/0x270
> > > [  310.315330]  ? inet_sendmsg+0x111/0x590
> > > [  310.316100]  ? sock_sendmsg+0xba/0xf0
> > > [  310.317403]  ? sock_write_iter+0x2e4/0x6a0
> > > [  310.318759]  ? __rb_erase_color+0x27d0/0x27d0
> > > [  310.319949]  ? rt_cpu_seq_show+0x2d0/0x2d0
> > > [  310.320800]  ? update_stack_state+0x402/0x780
> > > [  310.321590]  ip_finish_output+0x407/0x880
> > > [  310.322347]  ? ip_finish_output+0x407/0x880
> > > [  310.323138]  ? update_stack_state+0x402/0x780
> > > [  310.323948]  ip_output+0x1c0/0x640
> > > [  310.324661]  ? ip_mc_output+0x1350/0x1350
> > > [  310.325415]  ? __sk_dst_check+0x164/0x370
> > > [  310.326169]  ? complete_formation.isra.53+0xa30/0xa30
> > > [  310.327013]  ? __read_once_size_nocheck.constprop.7+0x20/0x20
> > > [  310.327896]  ? sock_prot_inuse_add+0xa0/0xa0
> > > [  310.328684]  ? memcpy+0x45/0x50
> > > [  310.329393]  ? __copy_skb_header+0x1fa/0x280
> > > [  310.330180]  ip_local_out+0x70/0x90
> > > [  310.330914]  ip_queue_xmit+0x8a1/0x22a0
> > > [  310.331676]  ? ip_build_and_send_pkt+0xe80/0xe80
> > > [  310.332517]  ? tcp_v4_md5_lookup+0x13/0x20
> > > [  310.333298]  tcp_transmit_skb+0x187a/0x3e00
> > > [  310.334085]  ? __tcp_select_window+0xaf0/0xaf0
> > > [  310.334887]  ? sock_sendmsg+0xba/0xf0
> > > [  310.335637]  ? __vfs_write+0x4e0/0x960
> > > [  310.336391]  ? vfs_write+0x155/0x4b0
> > > [  310.337135]  ? SyS_write+0xf7/0x240
> > > [  310.337861]  ? do_syscall_64+0x235/0x5b0
> > > [  310.338612]  ? entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.339443]  ? sock_sendmsg+0xba/0xf0
> > > [  310.341675]  ? do_syscall_64+0x235/0x5b0
> > > [  310.342441]  ? entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.343298]  ? tcp_init_tso_segs+0x1e0/0x1e0
> > > [  310.344095]  ? radix_tree_lookup+0xd/0x10
> > > [  310.344871]  ? get_work_pool+0xcd/0x150
> > > [  310.345635]  ? check_flush_dependency+0x330/0x330
> > > [  310.346466]  tcp_write_xmit+0x498/0x52a0
> > > [  310.347826]  ? kasan_unpoison_shadow+0x35/0x50
> > > [  310.349243]  ? kasan_kmalloc+0xad/0xe0
> > > [  310.350156]  ? tcp_transmit_skb+0x3e00/0x3e00
> > > [  310.351261]  ? memset+0x31/0x40
> > > [  310.352054]  ? __check_object_size+0x22e/0x55c
> > > [  310.352881]  ? skb_pull_rcsum+0x2b0/0x2b0
> > > [  310.353686]  ? check_stack_object+0x120/0x120
> > > [  310.354506]  ? tcp_v4_md5_lookup+0x13/0x20
> > > [  310.355327]  __tcp_push_pending_frames+0x8d/0x2a0
> > > [  310.356174]  ? tcp_cwnd_restart+0x169/0x440
> > > [  310.357016]  tcp_push+0x47c/0xbd0
> > > [  310.357777]  ? copy_from_iter_full+0x21e/0xc70
> > > [  310.358618]  ? tcp_splice_data_recv+0x1c0/0x1c0
> > > [  310.359463]  ? iov_iter_copy_from_user_atomic+0xeb0/0xeb0
> > > [  310.360355]  ? tcp_send_mss+0x24/0x2b0
> > > [  310.361135]  tcp_sendmsg+0xd6d/0x43f0
> > > [  310.361908]  ? select_estimate_accuracy+0x440/0x440
> > > [  310.362765]  ? tcp_sendpage+0x2170/0x2170
> > > [  310.363583]  ? set_fd_set.part.1+0x50/0x50
> > > [  310.364392]  ? remove_wait_queue+0x196/0x3b0
> > > [  310.365205]  ? set_fd_set.part.1+0x50/0x50
> > > [  310.366005]  ? add_wait_queue_exclusive+0x290/0x290
> > > [  310.366865]  ? __wake_up+0x44/0x50
> > > [  310.367637]  ? n_tty_read+0x9f9/0x19d0
> > > [  310.368424]  ? update_blocked_averages+0x9a0/0x9a0
> > > [  310.369283]  ? __check_object_size+0x22e/0x55c
> > > [  310.370129]  inet_sendmsg+0x111/0x590
> > > [  310.371104]  ? inet_recvmsg+0x5e0/0x5e0
> > > [  310.372571]  ? inet_recvmsg+0x5e0/0x5e0
> > > [  310.373449]  sock_sendmsg+0xba/0xf0
> > > [  310.374217]  sock_write_iter+0x2e4/0x6a0
> > > [  310.375005]  ? core_sys_select+0x47d/0x780
> > > [  310.375822]  ? sock_sendmsg+0xf0/0xf0
> > > [  310.376607]  __vfs_write+0x4e0/0x960
> > > [  310.377463]  ? kvm_clock_get_cycles+0x1e/0x20
> > > [  310.378864]  ? __vfs_read+0x950/0x950
> > > [  310.380178]  ? rw_verify_area+0xbd/0x2b0
> > > [  310.381092]  vfs_write+0x155/0x4b0
> > > [  310.381877]  SyS_write+0xf7/0x240
> > > [  310.382616]  ? SyS_read+0x240/0x240
> > > [  310.383404]  ? SyS_read+0x240/0x240
> > > [  310.384159]  do_syscall_64+0x235/0x5b0
> > > [  310.384930]  ? trace_raw_output_sys_exit+0xf0/0xf0
> > > [  310.385747]  ? syscall_return_slowpath+0x240/0x240
> > > [  310.386564]  ? trace_do_page_fault+0xc4/0x3a0
> > > [  310.387424]  ? prepare_exit_to_usermode+0x124/0x160
> > > [  310.388524]  ? perf_trace_sys_enter+0x1080/0x1080
> > > [  310.389347]  entry_SYSCALL64_slow_path+0x25/0x25
> > > [  310.390164] RIP: 0033:0x7f301f83c070
> > > [  310.390906] RSP: 002b:00007ffff738fc78 EFLAGS: 00000246 ORIG_RAX:
> > > 0000000000000001
> > > [  310.391943] RAX: ffffffffffffffda RBX: 0000000000000564 RCX:
> > > 00007f301f83c070
> > > [  310.392938] RDX: 0000000000000564 RSI: 000055cf87fb0748 RDI:
> > > 0000000000000003
> > > [  310.393947] RBP: 000055cf87f8f090 R08: 0000000000000000 R09:
> > > 0000000000003000
> > > [  310.394948] R10: 0000000000000008 R11: 0000000000000246 R12:
> > > 0000000000000000
> > > [  310.395967] R13: 00007ffff738fd0f R14: 000055cf873dde31 R15:
> > > 0000000000000003
> > > [  310.396969] Code: 00 00 48 89 5d d0 31 db 80 3c 02 00 0f 85 05 02
> 00 00
> > > 49 8b 45 00 48 ba 00 00 00 00 00 fc ff df 48 8d 78 20 48 89 f9 48 c1
> e9 03
> > > <80> 3c 11 00 0f 85 04 02 00 00 48 8b 58 20 48 ba 00 00 00 00 00
> > > [  310.399937] RIP: free_old_xmit_skbs.isra.29+0x9d/0x2e0
> [virtio_net] RSP:
> > > ffff880069e46540
> > > [  310.401120] ---[ end trace 89c5b0ea3f07debe ]---
> > > [  310.403923] Kernel panic - not syncing: Fatal exception in interrupt
> > > [  310.405942] Kernel Offset: 0x33200000 from 0xffffffff81000000
> (relocation
> > > range: 0xffffffff80000000-0xffffffffbfffffff)
> > > [  310.408133] ---[ end Kernel panic - not syncing: Fatal exception in
> > > interrupt
> > >
> > >
> > > (gdb) l *(free_old_xmit_skbs+0x2b7)
> > > 0x22f7 is in free_old_xmit_skbs (drivers/net/virtio_net.c:1051).
> > > 1046
> > > 1047        static void free_old_xmit_skbs(struct send_queue *sq)
> > > 1048        {
> > > 1049                struct sk_buff *skb;
> > > 1050                unsigned int len;
> > > 1051                struct virtnet_info *vi = sq->vq->vdev->priv;
> > > 1052                struct virtnet_stats *stats =
> this_cpu_ptr(vi->stats);
> > > 1053                unsigned int packets = 0;
> > > 1054                unsigned int bytes = 0;
> > > 1055
> > >
> > > Let me know if i need to provide more informations.
> > >
> > > Best regards.
> > >
> > > Jean-Philippe
> >
> > So del_vq done during xdp setup seems to race with regular xmit.
> >
> > Since commit 680557cf79f82623e2c4fd42733077d60a843513
> >     virtio_net: rework mergeable buffer handling
> >
> > we no longer must do the resets, we now have enough space
> > to store a bit saying whether a buffer is xdp one or not.
> >
> > And that's probably a cleaner way to fix these issues than
> > try to find and fix the race condition.
> >
> > John?
> >
> > --
> > MST
>
>
> I think I see the source of the race. virtio net calls
> netif_device_detach and assumes no packets will be sent after
> this point. However, all it does is stop all queues so
> no new packets will be transmitted.
>
> Try locking with HARD_TX_LOCK?
>
>
> --
> MST
>

Hi Michael,

from what i see, the race appear when we hit virtnet_reset in
virtnet_xdp_set.
virtnet_reset
  _remove_vq_common
    virtnet_del_vqs
      virtnet_free_queues
        kfree(vi->sq)
when the xdp program (with two instances of the program to trigger it
faster) is added or removed.

It's easily repeatable, with 2 cpus and 4 queues on the qemu command line,
running the xdp_ttl tool from Jesper.

For now, i'm able to continue my qualification, testing if xdp_qp is not
null, but do not seem to be a sustainable trick.
if (xdp_qp && vi->xdp_queues_pairs != xdp_qp)

Maybe it will be more clear to you with theses informations.

Best regards.

Jean-Philippe

--001a11498f001909d50552866b18
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">2017-06-06 1:52 GMT+02:00 Michael S. Tsirkin <span dir=3D"=
ltr">&lt;<a href=3D"mailto:mst@redhat.com" target=3D"_blank">mst@redhat.com=
</a>&gt;</span>:<br><div class=3D"gmail_extra"><div class=3D"gmail_quote"><=
blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-l=
eft:1px solid rgb(204,204,204);padding-left:1ex"><div class=3D"gmail-m_7376=
334747779054513gmail-m_7718901651756234020gmail-HOEnZb"><div class=3D"gmail=
-m_7376334747779054513gmail-m_7718901651756234020gmail-h5">On Mon, Jun 05, =
2017 at 05:08:25AM +0300, Michael S. Tsirkin wrote:<br>
&gt; On Mon, Jun 05, 2017 at 12:48:53AM +0200, Jean-Philippe Menil wrote:<b=
r>
&gt; &gt; Hi,<br>
&gt; &gt;<br>
&gt; &gt; while playing with xdp and ebpf, i&#39;m hitting the following:<b=
r>
&gt; &gt;<br>
&gt; &gt; [=C2=A0 309.993136]<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; [=C2=A0 309.994735] BUG: KASAN: use-after-free in<br>
&gt; &gt; free_old_xmit_skbs.isra.29+0x2<wbr>b7/0x2e0 [virtio_net]<br>
&gt; &gt; [=C2=A0 309.998396] Read of size 8 at addr ffff88006aa64220 by ta=
sk sshd/323<br>
&gt; &gt; [=C2=A0 310.000650]<br>
&gt; &gt; [=C2=A0 310.002305] CPU: 1 PID: 323 Comm: sshd Not tainted 4.12.0=
-rc3+ #2<br>
&gt; &gt; [=C2=A0 310.004018] Hardware name: QEMU Standard PC (i440FX + PII=
X, 1996), BIOS<br>
&gt; &gt; 1.10.2-20170228_101828-anatol 04/01/2014<br>
&gt; &gt; [=C2=A0 310.006495] Call Trace:<br>
&gt; &gt; [=C2=A0 310.007610]=C2=A0 dump_stack+0xb8/0x14c<br>
&gt; &gt; [=C2=A0 310.008748]=C2=A0 ? _atomic_dec_and_lock+0x174/0x1<wbr>74=
<br>
&gt; &gt; [=C2=A0 310.009998]=C2=A0 ? pm_qos_get_value.part.7+0x6/0x<wbr>6<=
br>
&gt; &gt; [=C2=A0 310.011203]=C2=A0 print_address_description+0x6f<wbr>/0x2=
80<br>
&gt; &gt; [=C2=A0 310.012416]=C2=A0 kasan_report+0x27a/0x370<br>
&gt; &gt; [=C2=A0 310.013573]=C2=A0 ? free_old_xmit_skbs.isra.29+0x2<wbr>b7=
/0x2e0 [virtio_net]<br>
&gt; &gt; [=C2=A0 310.014900]=C2=A0 __asan_report_load8_noabort+0x<wbr>19/0=
x20<br>
&gt; &gt; [=C2=A0 310.016136]=C2=A0 free_old_xmit_skbs.isra.29+0x2<wbr>b7/0=
x2e0 [virtio_net]<br>
&gt; &gt; [=C2=A0 310.017467]=C2=A0 ? virtnet_del_vqs+0xe0/0xe0 [virtio_net=
]<br>
&gt; &gt; [=C2=A0 310.018759]=C2=A0 ? packet_rcv+0x20d0/0x20d0<br>
&gt; &gt; [=C2=A0 310.019950]=C2=A0 ? dev_queue_xmit_nit+0x5cd/0xaf0<br>
&gt; &gt; [=C2=A0 310.021168]=C2=A0 start_xmit+0x1b4/0x1b10 [virtio_net]<br=
>
&gt; &gt; [=C2=A0 310.022413]=C2=A0 ? default_device_exit+0x2d0/0x2d<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.023634]=C2=A0 ? virtnet_remove+0xf0/0xf0 [virtio_net]=
<br>
&gt; &gt; [=C2=A0 310.024874]=C2=A0 ? update_load_avg+0x1281/0x29f0<br>
&gt; &gt; [=C2=A0 310.026059]=C2=A0 dev_hard_start_xmit+0x1ea/0x7f<wbr>0<br=
>
&gt; &gt; [=C2=A0 310.027247]=C2=A0 ? validate_xmit_skb_list+0x100/0<wbr>x1=
00<br>
&gt; &gt; [=C2=A0 310.028470]=C2=A0 ? validate_xmit_skb+0x7f/0xc10<br>
&gt; &gt; [=C2=A0 310.029731]=C2=A0 ? netif_skb_features+0x920/0x920<br>
&gt; &gt; [=C2=A0 310.033469]=C2=A0 ? __skb_tx_hash+0x2f0/0x2f0<br>
&gt; &gt; [=C2=A0 310.035615]=C2=A0 ? validate_xmit_skb_list+0xa3/0x<wbr>10=
0<br>
&gt; &gt; [=C2=A0 310.037782]=C2=A0 sch_direct_xmit+0x2eb/0x7a0<br>
&gt; &gt; [=C2=A0 310.039842]=C2=A0 ? dev_deactivate_queue.constprop<wbr>.2=
9+0x230/0x230<br>
&gt; &gt; [=C2=A0 310.041980]=C2=A0 ? netdev_pick_tx+0x212/0x2b0<br>
&gt; &gt; [=C2=A0 310.043868]=C2=A0 __dev_queue_xmit+0x12fa/0x20b0<br>
&gt; &gt; [=C2=A0 310.045564]=C2=A0 ? netdev_pick_tx+0x2b0/0x2b0<br>
&gt; &gt; [=C2=A0 310.047210]=C2=A0 ? __account_cfs_rq_runtime+0x630<wbr>/0=
x630<br>
&gt; &gt; [=C2=A0 310.048301]=C2=A0 ? update_stack_state+0x402/0x780<br>
&gt; &gt; [=C2=A0 310.049307]=C2=A0 ? account_entity_enqueue+0x730/0<wbr>x7=
30<br>
&gt; &gt; [=C2=A0 310.050322]=C2=A0 ? __rb_erase_color+0x27d0/0x27d0<br>
&gt; &gt; [=C2=A0 310.051286]=C2=A0 ? update_curr_fair+0x70/0x70<br>
&gt; &gt; [=C2=A0 310.052206]=C2=A0 ? enqueue_entity+0x2450/0x2450<br>
&gt; &gt; [=C2=A0 310.053124]=C2=A0 ? entry_SYSCALL64_slow_path+0x25<wbr>/0=
x25<br>
&gt; &gt; [=C2=A0 310.054082]=C2=A0 ? dequeue_entity+0x27a/0x1520<br>
&gt; &gt; [=C2=A0 310.054967]=C2=A0 ? bpf_prog_alloc+0x320/0x320<br>
&gt; &gt; [=C2=A0 310.055822]=C2=A0 ? yield_to_task_fair+0x110/0x110<br>
&gt; &gt; [=C2=A0 310.056708]=C2=A0 ? set_next_entity+0x2f2/0xa90<br>
&gt; &gt; [=C2=A0 310.057574]=C2=A0 ? dequeue_task_fair+0xc09/0x2ec0<br>
&gt; &gt; [=C2=A0 310.058457]=C2=A0 dev_queue_xmit+0x10/0x20<br>
&gt; &gt; [=C2=A0 310.059298]=C2=A0 ip_finish_output2+0xacf/0x12a0<br>
&gt; &gt; [=C2=A0 310.060160]=C2=A0 ? dequeue_entity+0x1520/0x1520<br>
&gt; &gt; [=C2=A0 310.063410]=C2=A0 ? ip_fragment.constprop.47+0x220<wbr>/0=
x220<br>
&gt; &gt; [=C2=A0 310.065078]=C2=A0 ? ring_buffer_set_clock+0x50/0x5<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.066677]=C2=A0 ? __switch_to+0x685/0xda0<br>
&gt; &gt; [=C2=A0 310.068166]=C2=A0 ? load_balance+0x38f0/0x38f0<br>
&gt; &gt; [=C2=A0 310.069544]=C2=A0 ? compat_start_thread+0x80/0x80<br>
&gt; &gt; [=C2=A0 310.070989]=C2=A0 ? trace_find_cmdline+0x60/0x60<br>
&gt; &gt; [=C2=A0 310.072402]=C2=A0 ? rt_cpu_seq_show+0x2d0/0x2d0<br>
&gt; &gt; [=C2=A0 310.073579]=C2=A0 ip_finish_output+0x407/0x880<br>
&gt; &gt; [=C2=A0 310.074441]=C2=A0 ? ip_finish_output+0x407/0x880<br>
&gt; &gt; [=C2=A0 310.075255]=C2=A0 ? update_stack_state+0x402/0x780<br>
&gt; &gt; [=C2=A0 310.076076]=C2=A0 ip_output+0x1c0/0x640<br>
&gt; &gt; [=C2=A0 310.076843]=C2=A0 ? ip_mc_output+0x1350/0x1350<br>
&gt; &gt; [=C2=A0 310.077642]=C2=A0 ? __sk_dst_check+0x164/0x370<br>
&gt; &gt; [=C2=A0 310.078441]=C2=A0 ? complete_formation.isra.53+0xa<wbr>30=
/0xa30<br>
&gt; &gt; [=C2=A0 310.079313]=C2=A0 ? __read_once_size_nocheck.const<wbr>pr=
op.7+0x20/0x20<br>
&gt; &gt; [=C2=A0 310.080265]=C2=A0 ? sock_prot_inuse_add+0xa0/0xa0<br>
&gt; &gt; [=C2=A0 310.081097]=C2=A0 ? memcpy+0x45/0x50<br>
&gt; &gt; [=C2=A0 310.081850]=C2=A0 ? __copy_skb_header+0x1fa/0x280<br>
&gt; &gt; [=C2=A0 310.082676]=C2=A0 ip_local_out+0x70/0x90<br>
&gt; &gt; [=C2=A0 310.083448]=C2=A0 ip_queue_xmit+0x8a1/0x22a0<br>
&gt; &gt; [=C2=A0 310.084236]=C2=A0 ? ip_build_and_send_pkt+0xe80/0x<wbr>e8=
0<br>
&gt; &gt; [=C2=A0 310.085079]=C2=A0 ? tcp_v4_md5_lookup+0x13/0x20<br>
&gt; &gt; [=C2=A0 310.085884]=C2=A0 tcp_transmit_skb+0x187a/0x3e00<br>
&gt; &gt; [=C2=A0 310.086696]=C2=A0 ? __tcp_select_window+0xaf0/0xaf<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.087524]=C2=A0 ? sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.088298]=C2=A0 ? __vfs_write+0x4e0/0x960<br>
&gt; &gt; [=C2=A0 310.089074]=C2=A0 ? vfs_write+0x155/0x4b0<br>
&gt; &gt; [=C2=A0 310.089838]=C2=A0 ? SyS_write+0xf7/0x240<br>
&gt; &gt; [=C2=A0 310.090593]=C2=A0 ? do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.091372]=C2=A0 ? entry_SYSCALL64_slow_path+0x25<wbr>/0=
x25<br>
&gt; &gt; [=C2=A0 310.094690]=C2=A0 ? sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.096133]=C2=A0 ? do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.097593]=C2=A0 ? entry_SYSCALL64_slow_path+0x25<wbr>/0=
x25<br>
&gt; &gt; [=C2=A0 310.099157]=C2=A0 ? tcp_init_tso_segs+0x1e0/0x1e0<br>
&gt; &gt; [=C2=A0 310.100539]=C2=A0 ? radix_tree_lookup+0xd/0x10<br>
&gt; &gt; [=C2=A0 310.101894]=C2=A0 ? get_work_pool+0xcd/0x150<br>
&gt; &gt; [=C2=A0 310.103216]=C2=A0 ? check_flush_dependency+0x330/0<wbr>x3=
30<br>
&gt; &gt; [=C2=A0 310.104113]=C2=A0 tcp_write_xmit+0x498/0x52a0<br>
&gt; &gt; [=C2=A0 310.104905]=C2=A0 ? kasan_unpoison_shadow+0x35/0x5<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.105729]=C2=A0 ? kasan_kmalloc+0xad/0xe0<br>
&gt; &gt; [=C2=A0 310.106505]=C2=A0 ? tcp_transmit_skb+0x3e00/0x3e00<br>
&gt; &gt; [=C2=A0 310.107331]=C2=A0 ? memset+0x31/0x40<br>
&gt; &gt; [=C2=A0 310.108070]=C2=A0 ? __check_object_size+0x22e/0x55<wbr>c<=
br>
&gt; &gt; [=C2=A0 310.108895]=C2=A0 ? skb_pull_rcsum+0x2b0/0x2b0<br>
&gt; &gt; [=C2=A0 310.109690]=C2=A0 ? check_stack_object+0x120/0x120<br>
&gt; &gt; [=C2=A0 310.110512]=C2=A0 ? tcp_v4_md5_lookup+0x13/0x20<br>
&gt; &gt; [=C2=A0 310.111315]=C2=A0 __tcp_push_pending_frames+0x8d<wbr>/0x2=
a0<br>
&gt; &gt; [=C2=A0 310.112159]=C2=A0 tcp_push+0x47c/0xbd0<br>
&gt; &gt; [=C2=A0 310.112912]=C2=A0 ? copy_from_iter_full+0x21e/0xc7<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.113747]=C2=A0 ? sock_warn_obsolete_bsdism+0x70<wbr>/0=
x70<br>
&gt; &gt; [=C2=A0 310.114604]=C2=A0 ? tcp_splice_data_recv+0x1c0/0x1<wbr>c0=
<br>
&gt; &gt; [=C2=A0 310.115436]=C2=A0 ? iov_iter_copy_from_user_atomic<wbr>+0=
xeb0/0xeb0<br>
&gt; &gt; [=C2=A0 310.116324]=C2=A0 tcp_sendmsg+0xd6d/0x43f0<br>
&gt; &gt; [=C2=A0 310.117106]=C2=A0 ? tcp_sendpage+0x2170/0x2170<br>
&gt; &gt; [=C2=A0 310.117911]=C2=A0 ? set_fd_set.part.1+0x50/0x50<br>
&gt; &gt; [=C2=A0 310.118718]=C2=A0 ? remove_wait_queue+0x196/0x3b0<br>
&gt; &gt; [=C2=A0 310.119535]=C2=A0 ? set_fd_set.part.1+0x50/0x50<br>
&gt; &gt; [=C2=A0 310.120365]=C2=A0 ? add_wait_queue_exclusive+0x290<wbr>/0=
x290<br>
&gt; &gt; [=C2=A0 310.121224]=C2=A0 ? __wake_up+0x44/0x50<br>
&gt; &gt; [=C2=A0 310.121985]=C2=A0 ? n_tty_read+0x9f9/0x19d0<br>
&gt; &gt; [=C2=A0 310.122898]=C2=A0 ? __check_object_size+0x22e/0x55<wbr>c<=
br>
&gt; &gt; [=C2=A0 310.125380]=C2=A0 inet_sendmsg+0x111/0x590<br>
&gt; &gt; [=C2=A0 310.126863]=C2=A0 ? inet_recvmsg+0x5e0/0x5e0<br>
&gt; &gt; [=C2=A0 310.128348]=C2=A0 ? inet_recvmsg+0x5e0/0x5e0<br>
&gt; &gt; [=C2=A0 310.129817]=C2=A0 sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.131110]=C2=A0 sock_write_iter+0x2e4/0x6a0<br>
&gt; &gt; [=C2=A0 310.132433]=C2=A0 ? core_sys_select+0x47d/0x780<br>
&gt; &gt; [=C2=A0 310.133779]=C2=A0 ? sock_sendmsg+0xf0/0xf0<br>
&gt; &gt; [=C2=A0 310.134591]=C2=A0 __vfs_write+0x4e0/0x960<br>
&gt; &gt; [=C2=A0 310.135351]=C2=A0 ? kvm_clock_get_cycles+0x1e/0x20<br>
&gt; &gt; [=C2=A0 310.136160]=C2=A0 ? __vfs_read+0x950/0x950<br>
&gt; &gt; [=C2=A0 310.136931]=C2=A0 ? rw_verify_area+0xbd/0x2b0<br>
&gt; &gt; [=C2=A0 310.137711]=C2=A0 vfs_write+0x155/0x4b0<br>
&gt; &gt; [=C2=A0 310.138454]=C2=A0 SyS_write+0xf7/0x240<br>
&gt; &gt; [=C2=A0 310.139183]=C2=A0 ? SyS_read+0x240/0x240<br>
&gt; &gt; [=C2=A0 310.139922]=C2=A0 ? SyS_read+0x240/0x240<br>
&gt; &gt; [=C2=A0 310.140649]=C2=A0 do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.141390]=C2=A0 ? trace_raw_output_sys_exit+0xf0<wbr>/0=
xf0<br>
&gt; &gt; [=C2=A0 310.142204]=C2=A0 ? syscall_return_slowpath+0x240/<wbr>0x=
240<br>
&gt; &gt; [=C2=A0 310.143018]=C2=A0 ? trace_do_page_fault+0xc4/0x3a0<br>
&gt; &gt; [=C2=A0 310.143810]=C2=A0 ? prepare_exit_to_usermode+0x124<wbr>/0=
x160<br>
&gt; &gt; [=C2=A0 310.144634]=C2=A0 ? perf_trace_sys_enter+0x1080/0x<wbr>10=
80<br>
&gt; &gt; [=C2=A0 310.145447]=C2=A0 entry_SYSCALL64_slow_path+0x25<wbr>/0x2=
5<br>
&gt; &gt; [=C2=A0 310.146257] RIP: 0033:0x7f6f868fb070<br>
&gt; &gt; [=C2=A0 310.146999] RSP: 002b:00007fffed379578 EFLAGS: 00000246 O=
RIG_RAX:<br>
&gt; &gt; 0000000000000001<br>
&gt; &gt; [=C2=A0 310.148507] RAX: ffffffffffffffda RBX: 00000000000002e4 R=
CX:<br>
&gt; &gt; 00007f6f868fb070<br>
&gt; &gt; [=C2=A0 310.149521] RDX: 00000000000002e4 RSI: 000055603b5cfc10 R=
DI:<br>
&gt; &gt; 0000000000000003<br>
&gt; &gt; [=C2=A0 310.150532] RBP: 000055603b5aca60 R08: 0000000000000000 R=
09:<br>
&gt; &gt; 0000000000003000<br>
&gt; &gt; [=C2=A0 310.151530] R10: 0000000000000008 R11: 0000000000000246 R=
12:<br>
&gt; &gt; 0000000000000000<br>
&gt; &gt; [=C2=A0 310.152537] R13: 00007fffed37960f R14: 000055603a832e31 R=
15:<br>
&gt; &gt; 0000000000000003<br>
&gt; &gt; [=C2=A0 310.153578]<br>
&gt; &gt; [=C2=A0 310.156362] Allocated by task 483:<br>
&gt; &gt; [=C2=A0 310.157812]=C2=A0 save_stack_trace+0x1b/0x20<br>
&gt; &gt; [=C2=A0 310.159274]=C2=A0 save_stack+0x43/0xd0<br>
&gt; &gt; [=C2=A0 310.160663]=C2=A0 kasan_kmalloc+0xad/0xe0<br>
&gt; &gt; [=C2=A0 310.161943]=C2=A0 __kmalloc+0x105/0x230<br>
&gt; &gt; [=C2=A0 310.163233]=C2=A0 __vring_new_virtqueue+0xd1/0xe<wbr>e0<b=
r>
&gt; &gt; [=C2=A0 310.164623]=C2=A0 vring_create_virtqueue+0x2e3/0<wbr>x5e0=
<br>
&gt; &gt; [=C2=A0 310.165536]=C2=A0 setup_vq+0x136/0x620<br>
&gt; &gt; [=C2=A0 310.166286]=C2=A0 vp_setup_vq+0x13d/0x6d0<br>
&gt; &gt; [=C2=A0 310.167059]=C2=A0 vp_find_vqs_msix+0x46c/0xb50<br>
&gt; &gt; [=C2=A0 310.167855]=C2=A0 vp_find_vqs+0x71/0x410<br>
&gt; &gt; [=C2=A0 310.168641]=C2=A0 vp_modern_find_vqs+0x21/0x140<br>
&gt; &gt; [=C2=A0 310.169453]=C2=A0 init_vqs+0x957/0x1390 [virtio_net]<br>
&gt; &gt; [=C2=A0 310.170306]=C2=A0 virtnet_restore_up+0x4a/0x590 [virtio_n=
et]<br>
&gt; &gt; [=C2=A0 310.171214]=C2=A0 virtnet_xdp+0x89f/0xdf0 [virtio_net]<br=
>
&gt; &gt; [=C2=A0 310.172077]=C2=A0 dev_change_xdp_fd+0x1ca/0x420<br>
&gt; &gt; [=C2=A0 310.172918]=C2=A0 do_setlink+0x2c33/0x3bc0<br>
&gt; &gt; [=C2=A0 310.173703]=C2=A0 rtnl_setlink+0x245/0x380<br>
&gt; &gt; [=C2=A0 310.174511]=C2=A0 rtnetlink_rcv_msg+0x530/0x9b0<br>
&gt; &gt; [=C2=A0 310.175344]=C2=A0 netlink_rcv_skb+0x213/0x450<br>
&gt; &gt; [=C2=A0 310.176166]=C2=A0 rtnetlink_rcv+0x28/0x30<br>
&gt; &gt; [=C2=A0 310.176990]=C2=A0 netlink_unicast+0x4a0/0x6c0<br>
&gt; &gt; [=C2=A0 310.177807]=C2=A0 netlink_sendmsg+0x9ec/0xe50<br>
&gt; &gt; [=C2=A0 310.178646]=C2=A0 sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.179435]=C2=A0 SYSC_sendto+0x31d/0x620<br>
&gt; &gt; [=C2=A0 310.180229]=C2=A0 SyS_sendto+0xe/0x10<br>
&gt; &gt; [=C2=A0 310.181004]=C2=A0 do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.181783]=C2=A0 return_from_SYSCALL_64+0x0/0x6<wbr>a<br=
>
&gt; &gt; [=C2=A0 310.182595]<br>
&gt; &gt; [=C2=A0 310.183217] Freed by task 483:<br>
&gt; &gt; [=C2=A0 310.183934]=C2=A0 save_stack_trace+0x1b/0x20<br>
&gt; &gt; [=C2=A0 310.184801]=C2=A0 save_stack+0x43/0xd0<br>
&gt; &gt; [=C2=A0 310.187187]=C2=A0 kasan_slab_free+0x72/0xc0<br>
&gt; &gt; [=C2=A0 310.188530]=C2=A0 kfree+0x94/0x1a0<br>
&gt; &gt; [=C2=A0 310.189797]=C2=A0 vring_del_virtqueue+0x19a/0x43<wbr>0<br=
>
&gt; &gt; [=C2=A0 310.191221]=C2=A0 del_vq+0x11c/0x250<br>
&gt; &gt; [=C2=A0 310.192474]=C2=A0 vp_del_vqs+0x379/0xc30<br>
&gt; &gt; [=C2=A0 310.193772]=C2=A0 virtnet_del_vqs+0xad/0xe0 [virtio_net]<=
br>
&gt; &gt; [=C2=A0 310.195064]=C2=A0 virtnet_xdp+0x836/0xdf0 [virtio_net]<br=
>
&gt; &gt; [=C2=A0 310.196231]=C2=A0 dev_change_xdp_fd+0x37c/0x420<br>
&gt; &gt; [=C2=A0 310.197072]=C2=A0 do_setlink+0x2c33/0x3bc0<br>
&gt; &gt; [=C2=A0 310.197804]=C2=A0 rtnl_setlink+0x245/0x380<br>
&gt; &gt; [=C2=A0 310.198530]=C2=A0 rtnetlink_rcv_msg+0x530/0x9b0<br>
&gt; &gt; [=C2=A0 310.199283]=C2=A0 netlink_rcv_skb+0x213/0x450<br>
&gt; &gt; [=C2=A0 310.200036]=C2=A0 rtnetlink_rcv+0x28/0x30<br>
&gt; &gt; [=C2=A0 310.200754]=C2=A0 netlink_unicast+0x4a0/0x6c0<br>
&gt; &gt; [=C2=A0 310.201496]=C2=A0 netlink_sendmsg+0x9ec/0xe50<br>
&gt; &gt; [=C2=A0 310.202236]=C2=A0 sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.202947]=C2=A0 SYSC_sendto+0x31d/0x620<br>
&gt; &gt; [=C2=A0 310.203660]=C2=A0 SyS_sendto+0xe/0x10<br>
&gt; &gt; [=C2=A0 310.204340]=C2=A0 do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.205050]=C2=A0 return_from_SYSCALL_64+0x0/0x6<wbr>a<br=
>
&gt; &gt; [=C2=A0 310.205792]<br>
&gt; &gt; [=C2=A0 310.206350] The buggy address belongs to the object at ff=
ff88006aa64200<br>
&gt; &gt; [=C2=A0 310.206350]=C2=A0 which belongs to the cache kmalloc-8192=
 of size 8192<br>
&gt; &gt; [=C2=A0 310.208149] The buggy address is located 32 bytes inside =
of<br>
&gt; &gt; [=C2=A0 310.208149]=C2=A0 8192-byte region [ffff88006aa64200, fff=
f88006aa66200)<br>
&gt; &gt; [=C2=A0 310.209929] The buggy address belongs to the page:<br>
&gt; &gt; [=C2=A0 310.210763] page:ffffea0001aa9800 count:1 mapcount:0 mapp=
ing:=C2=A0 (null)<br>
&gt; &gt; index:0x0 compound_mapcount: 0<br>
&gt; &gt; [=C2=A0 310.212499] flags: 0x1ffff8000008100(slab|head)<br>
&gt; &gt; [=C2=A0 310.213373] raw: 01ffff8000008100 0000000000000000 000000=
0000000000<br>
&gt; &gt; 0000000100030003<br>
&gt; &gt; [=C2=A0 310.214481] raw: dead000000000100 dead000000000200 ffff88=
006cc02700<br>
&gt; &gt; 0000000000000000<br>
&gt; &gt; [=C2=A0 310.215635] page dumped because: kasan: bad access detect=
ed<br>
&gt; &gt; [=C2=A0 310.218989]<br>
&gt; &gt; [=C2=A0 310.220398] Memory state around the buggy address:<br>
&gt; &gt; [=C2=A0 310.222141]=C2=A0 ffff88006aa64100: fc fc fc fc fc fc fc =
fc fc fc fc fc fc fc<br>
&gt; &gt; fc fc<br>
&gt; &gt; [=C2=A0 310.223996]=C2=A0 ffff88006aa64180: fc fc fc fc fc fc fc =
fc fc fc fc fc fc fc<br>
&gt; &gt; fc fc<br>
&gt; &gt; [=C2=A0 310.225469] &gt;ffff88006aa64200: fb fb fb fb fb fb fb fb=
 fb fb fb fb fb fb<br>
&gt; &gt; fb fb<br>
&gt; &gt; [=C2=A0 310.227400]=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ^<br>
&gt; &gt; [=C2=A0 310.228367]=C2=A0 ffff88006aa64280: fb fb fb fb fb fb fb =
fb fb fb fb fb fb fb<br>
&gt; &gt; fb fb<br>
&gt; &gt; [=C2=A0 310.229510]=C2=A0 ffff88006aa64300: fb fb fb fb fb fb fb =
fb fb fb fb fb fb fb<br>
&gt; &gt; fb fb<br>
&gt; &gt; [=C2=A0 310.230639]<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; [=C2=A0 310.231788] Disabling lock debugging due to kernel taint<=
br>
&gt; &gt; [=C2=A0 310.233499] kasan: CONFIG_KASAN_INLINE enabled<br>
&gt; &gt; [=C2=A0 310.236846] kasan: GPF could be caused by NULL-ptr deref =
or user memory<br>
&gt; &gt; access<br>
&gt; &gt; [=C2=A0 310.239138] general protection fault: 0000 [#1] SMP KASAN=
<br>
&gt; &gt; [=C2=A0 310.240926] Modules linked in: joydev kvm_intel kvm psmou=
se irqbypass<br>
&gt; &gt; i2c_piix4 qemu_fw_cfg ip_tables x_tables autofs4 serio_raw virtio=
_balloon<br>
&gt; &gt; pata_acpi virtio_net virtio_blk<br>
&gt; &gt; [=C2=A0 310.243618] CPU: 0 PID: 352 Comm: sshd Tainted: G=C2=A0 =
=C2=A0 B 4.12.0-rc3+ #2<br>
&gt; &gt; [=C2=A0 310.245780] Hardware name: QEMU Standard PC (i440FX + PII=
X, 1996), BIOS<br>
&gt; &gt; 1.10.2-20170228_101828-anatol 04/01/2014<br>
&gt; &gt; [=C2=A0 310.249799] task: ffff880066ca8d80 task.stack: ffff880069=
e40000<br>
&gt; &gt; [=C2=A0 310.251090] RIP: 0010:free_old_xmit_skbs.isra.2<wbr>9+0x9=
d/0x2e0 [virtio_net]<br>
&gt; &gt; [=C2=A0 310.252403] RSP: 0018:ffff880069e46540 EFLAGS: 00010202<b=
r>
&gt; &gt; [=C2=A0 310.253631] RAX: 0000000000000000 RBX: 0000000000000000 R=
CX:<br>
&gt; &gt; 0000000000000004<br>
&gt; &gt; [=C2=A0 310.255916] RDX: dffffc0000000000 RSI: 0000000000000008 R=
DI:<br>
&gt; &gt; 0000000000000020<br>
&gt; &gt; [=C2=A0 310.258017] RBP: ffff880069e465e8 R08: ffff880069e45f10 R=
09:<br>
&gt; &gt; ffff880066b3c400<br>
&gt; &gt; [=C2=A0 310.259430] R10: ffff880069e45e98 R11: 1ffff1000cd952f3 R=
12:<br>
&gt; &gt; ffff880066b3c400<br>
&gt; &gt; [=C2=A0 310.260797] R13: ffff880066b3c400 R14: ffff88006afc9156 R=
15:<br>
&gt; &gt; ffff88006afc9001<br>
&gt; &gt; [=C2=A0 310.262139] FS:=C2=A0 00007f3020f26680(0000) GS:ffff88006=
d000000(0000)<br>
&gt; &gt; knlGS:0000000000000000<br>
&gt; &gt; [=C2=A0 310.263564] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000=
080050033<br>
&gt; &gt; [=C2=A0 310.264825] CR2: 00007efed4534010 CR3: 000000006986d000 C=
R4:<br>
&gt; &gt; 00000000000006f0<br>
&gt; &gt; [=C2=A0 310.266178] Call Trace:<br>
&gt; &gt; [=C2=A0 310.267231]=C2=A0 ? virtnet_del_vqs+0xe0/0xe0 [virtio_net=
]<br>
&gt; &gt; [=C2=A0 310.268453]=C2=A0 ? packet_rcv+0x20d0/0x20d0<br>
&gt; &gt; [=C2=A0 310.269559]=C2=A0 start_xmit+0x1b4/0x1b10 [virtio_net]<br=
>
&gt; &gt; [=C2=A0 310.270762]=C2=A0 ? default_device_exit+0x2d0/0x2d<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.271910]=C2=A0 ? virtnet_remove+0xf0/0xf0 [virtio_net]=
<br>
&gt; &gt; [=C2=A0 310.273076]=C2=A0 ? update_load_avg+0x1281/0x29f0<br>
&gt; &gt; [=C2=A0 310.274189]=C2=A0 dev_hard_start_xmit+0x1ea/0x7f<wbr>0<br=
>
&gt; &gt; [=C2=A0 310.275295]=C2=A0 ? validate_xmit_skb_list+0x100/0<wbr>x1=
00<br>
&gt; &gt; [=C2=A0 310.276425]=C2=A0 ? validate_xmit_skb+0x7f/0xc10<br>
&gt; &gt; [=C2=A0 310.277548]=C2=A0 ? rb_insert_color+0x1590/0x1590<br>
&gt; &gt; [=C2=A0 310.280172]=C2=A0 ? netif_skb_features+0x920/0x920<br>
&gt; &gt; [=C2=A0 310.281275]=C2=A0 ? __skb_tx_hash+0x2f0/0x2f0<br>
&gt; &gt; [=C2=A0 310.282362]=C2=A0 ? validate_xmit_skb_list+0xa3/0x<wbr>10=
0<br>
&gt; &gt; [=C2=A0 310.283494]=C2=A0 sch_direct_xmit+0x2eb/0x7a0<br>
&gt; &gt; [=C2=A0 310.284559]=C2=A0 ? dev_deactivate_queue.constprop<wbr>.2=
9+0x230/0x230<br>
&gt; &gt; [=C2=A0 310.286448]=C2=A0 ? netdev_pick_tx+0x212/0x2b0<br>
&gt; &gt; [=C2=A0 310.288251]=C2=A0 ? __account_cfs_rq_runtime+0x630<wbr>/0=
x630<br>
&gt; &gt; [=C2=A0 310.289707]=C2=A0 __dev_queue_xmit+0x12fa/0x20b0<br>
&gt; &gt; [=C2=A0 310.290788]=C2=A0 ? netdev_pick_tx+0x2b0/0x2b0<br>
&gt; &gt; [=C2=A0 310.291837]=C2=A0 ? update_curr+0x1ef/0x750<br>
&gt; &gt; [=C2=A0 310.292826]=C2=A0 ? update_stack_state+0x402/0x780<br>
&gt; &gt; [=C2=A0 310.293827]=C2=A0 ? account_entity_enqueue+0x730/0<wbr>x7=
30<br>
&gt; &gt; [=C2=A0 310.294831]=C2=A0 ? update_stack_state+0x402/0x780<br>
&gt; &gt; [=C2=A0 310.295818]=C2=A0 ? update_curr_fair+0x70/0x70<br>
&gt; &gt; [=C2=A0 310.296737]=C2=A0 ? entry_SYSCALL64_slow_path+0x25<wbr>/0=
x25<br>
&gt; &gt; [=C2=A0 310.297693]=C2=A0 ? dequeue_entity+0x27a/0x1520<br>
&gt; &gt; [=C2=A0 310.298591]=C2=A0 ? bpf_prog_alloc+0x320/0x320<br>
&gt; &gt; [=C2=A0 310.299484]=C2=A0 ? yield_to_task_fair+0x110/0x110<br>
&gt; &gt; [=C2=A0 310.300385]=C2=A0 ? unwind_dump+0x4e0/0x4e0<br>
&gt; &gt; [=C2=A0 310.301246]=C2=A0 ? __free_insn_slot+0x600/0x600<br>
&gt; &gt; [=C2=A0 310.302125]=C2=A0 ? unwind_dump+0x4e0/0x4e0<br>
&gt; &gt; [=C2=A0 310.302975]=C2=A0 ? dequeue_task_fair+0xc09/0x2ec0<br>
&gt; &gt; [=C2=A0 310.303883]=C2=A0 dev_queue_xmit+0x10/0x20<br>
&gt; &gt; [=C2=A0 310.304711]=C2=A0 ip_finish_output2+0xacf/0x12a0<br>
&gt; &gt; [=C2=A0 310.305558]=C2=A0 ? dequeue_entity+0x1520/0x1520<br>
&gt; &gt; [=C2=A0 310.306393]=C2=A0 ? ip_fragment.constprop.47+0x220<wbr>/0=
x220<br>
&gt; &gt; [=C2=A0 310.307320]=C2=A0 ? save_stack_trace+0x1b/0x20<br>
&gt; &gt; [=C2=A0 310.308133]=C2=A0 ? save_stack+0x43/0xd0<br>
&gt; &gt; [=C2=A0 310.309081]=C2=A0 ? kasan_slab_free+0x72/0xc0<br>
&gt; &gt; [=C2=A0 310.310614]=C2=A0 ? kfree_skbmem+0xb6/0x1d0<br>
&gt; &gt; [=C2=A0 310.311406]=C2=A0 ? tcp_ack+0x2730/0x7450<br>
&gt; &gt; [=C2=A0 310.312167]=C2=A0 ? tcp_rcv_established+0xdbb/0x2d<wbr>b0=
<br>
&gt; &gt; [=C2=A0 310.312987]=C2=A0 ? tcp_v4_do_rcv+0x2bb/0x7a0<br>
&gt; &gt; [=C2=A0 310.313769]=C2=A0 ? __release_sock+0x14a/0x2b0<br>
&gt; &gt; [=C2=A0 310.314550]=C2=A0 ? release_sock+0xa8/0x270<br>
&gt; &gt; [=C2=A0 310.315330]=C2=A0 ? inet_sendmsg+0x111/0x590<br>
&gt; &gt; [=C2=A0 310.316100]=C2=A0 ? sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.317403]=C2=A0 ? sock_write_iter+0x2e4/0x6a0<br>
&gt; &gt; [=C2=A0 310.318759]=C2=A0 ? __rb_erase_color+0x27d0/0x27d0<br>
&gt; &gt; [=C2=A0 310.319949]=C2=A0 ? rt_cpu_seq_show+0x2d0/0x2d0<br>
&gt; &gt; [=C2=A0 310.320800]=C2=A0 ? update_stack_state+0x402/0x780<br>
&gt; &gt; [=C2=A0 310.321590]=C2=A0 ip_finish_output+0x407/0x880<br>
&gt; &gt; [=C2=A0 310.322347]=C2=A0 ? ip_finish_output+0x407/0x880<br>
&gt; &gt; [=C2=A0 310.323138]=C2=A0 ? update_stack_state+0x402/0x780<br>
&gt; &gt; [=C2=A0 310.323948]=C2=A0 ip_output+0x1c0/0x640<br>
&gt; &gt; [=C2=A0 310.324661]=C2=A0 ? ip_mc_output+0x1350/0x1350<br>
&gt; &gt; [=C2=A0 310.325415]=C2=A0 ? __sk_dst_check+0x164/0x370<br>
&gt; &gt; [=C2=A0 310.326169]=C2=A0 ? complete_formation.isra.53+0xa<wbr>30=
/0xa30<br>
&gt; &gt; [=C2=A0 310.327013]=C2=A0 ? __read_once_size_nocheck.const<wbr>pr=
op.7+0x20/0x20<br>
&gt; &gt; [=C2=A0 310.327896]=C2=A0 ? sock_prot_inuse_add+0xa0/0xa0<br>
&gt; &gt; [=C2=A0 310.328684]=C2=A0 ? memcpy+0x45/0x50<br>
&gt; &gt; [=C2=A0 310.329393]=C2=A0 ? __copy_skb_header+0x1fa/0x280<br>
&gt; &gt; [=C2=A0 310.330180]=C2=A0 ip_local_out+0x70/0x90<br>
&gt; &gt; [=C2=A0 310.330914]=C2=A0 ip_queue_xmit+0x8a1/0x22a0<br>
&gt; &gt; [=C2=A0 310.331676]=C2=A0 ? ip_build_and_send_pkt+0xe80/0x<wbr>e8=
0<br>
&gt; &gt; [=C2=A0 310.332517]=C2=A0 ? tcp_v4_md5_lookup+0x13/0x20<br>
&gt; &gt; [=C2=A0 310.333298]=C2=A0 tcp_transmit_skb+0x187a/0x3e00<br>
&gt; &gt; [=C2=A0 310.334085]=C2=A0 ? __tcp_select_window+0xaf0/0xaf<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.334887]=C2=A0 ? sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.335637]=C2=A0 ? __vfs_write+0x4e0/0x960<br>
&gt; &gt; [=C2=A0 310.336391]=C2=A0 ? vfs_write+0x155/0x4b0<br>
&gt; &gt; [=C2=A0 310.337135]=C2=A0 ? SyS_write+0xf7/0x240<br>
&gt; &gt; [=C2=A0 310.337861]=C2=A0 ? do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.338612]=C2=A0 ? entry_SYSCALL64_slow_path+0x25<wbr>/0=
x25<br>
&gt; &gt; [=C2=A0 310.339443]=C2=A0 ? sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.341675]=C2=A0 ? do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.342441]=C2=A0 ? entry_SYSCALL64_slow_path+0x25<wbr>/0=
x25<br>
&gt; &gt; [=C2=A0 310.343298]=C2=A0 ? tcp_init_tso_segs+0x1e0/0x1e0<br>
&gt; &gt; [=C2=A0 310.344095]=C2=A0 ? radix_tree_lookup+0xd/0x10<br>
&gt; &gt; [=C2=A0 310.344871]=C2=A0 ? get_work_pool+0xcd/0x150<br>
&gt; &gt; [=C2=A0 310.345635]=C2=A0 ? check_flush_dependency+0x330/0<wbr>x3=
30<br>
&gt; &gt; [=C2=A0 310.346466]=C2=A0 tcp_write_xmit+0x498/0x52a0<br>
&gt; &gt; [=C2=A0 310.347826]=C2=A0 ? kasan_unpoison_shadow+0x35/0x5<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.349243]=C2=A0 ? kasan_kmalloc+0xad/0xe0<br>
&gt; &gt; [=C2=A0 310.350156]=C2=A0 ? tcp_transmit_skb+0x3e00/0x3e00<br>
&gt; &gt; [=C2=A0 310.351261]=C2=A0 ? memset+0x31/0x40<br>
&gt; &gt; [=C2=A0 310.352054]=C2=A0 ? __check_object_size+0x22e/0x55<wbr>c<=
br>
&gt; &gt; [=C2=A0 310.352881]=C2=A0 ? skb_pull_rcsum+0x2b0/0x2b0<br>
&gt; &gt; [=C2=A0 310.353686]=C2=A0 ? check_stack_object+0x120/0x120<br>
&gt; &gt; [=C2=A0 310.354506]=C2=A0 ? tcp_v4_md5_lookup+0x13/0x20<br>
&gt; &gt; [=C2=A0 310.355327]=C2=A0 __tcp_push_pending_frames+0x8d<wbr>/0x2=
a0<br>
&gt; &gt; [=C2=A0 310.356174]=C2=A0 ? tcp_cwnd_restart+0x169/0x440<br>
&gt; &gt; [=C2=A0 310.357016]=C2=A0 tcp_push+0x47c/0xbd0<br>
&gt; &gt; [=C2=A0 310.357777]=C2=A0 ? copy_from_iter_full+0x21e/0xc7<wbr>0<=
br>
&gt; &gt; [=C2=A0 310.358618]=C2=A0 ? tcp_splice_data_recv+0x1c0/0x1<wbr>c0=
<br>
&gt; &gt; [=C2=A0 310.359463]=C2=A0 ? iov_iter_copy_from_user_atomic<wbr>+0=
xeb0/0xeb0<br>
&gt; &gt; [=C2=A0 310.360355]=C2=A0 ? tcp_send_mss+0x24/0x2b0<br>
&gt; &gt; [=C2=A0 310.361135]=C2=A0 tcp_sendmsg+0xd6d/0x43f0<br>
&gt; &gt; [=C2=A0 310.361908]=C2=A0 ? select_estimate_accuracy+0x440<wbr>/0=
x440<br>
&gt; &gt; [=C2=A0 310.362765]=C2=A0 ? tcp_sendpage+0x2170/0x2170<br>
&gt; &gt; [=C2=A0 310.363583]=C2=A0 ? set_fd_set.part.1+0x50/0x50<br>
&gt; &gt; [=C2=A0 310.364392]=C2=A0 ? remove_wait_queue+0x196/0x3b0<br>
&gt; &gt; [=C2=A0 310.365205]=C2=A0 ? set_fd_set.part.1+0x50/0x50<br>
&gt; &gt; [=C2=A0 310.366005]=C2=A0 ? add_wait_queue_exclusive+0x290<wbr>/0=
x290<br>
&gt; &gt; [=C2=A0 310.366865]=C2=A0 ? __wake_up+0x44/0x50<br>
&gt; &gt; [=C2=A0 310.367637]=C2=A0 ? n_tty_read+0x9f9/0x19d0<br>
&gt; &gt; [=C2=A0 310.368424]=C2=A0 ? update_blocked_averages+0x9a0/<wbr>0x=
9a0<br>
&gt; &gt; [=C2=A0 310.369283]=C2=A0 ? __check_object_size+0x22e/0x55<wbr>c<=
br>
&gt; &gt; [=C2=A0 310.370129]=C2=A0 inet_sendmsg+0x111/0x590<br>
&gt; &gt; [=C2=A0 310.371104]=C2=A0 ? inet_recvmsg+0x5e0/0x5e0<br>
&gt; &gt; [=C2=A0 310.372571]=C2=A0 ? inet_recvmsg+0x5e0/0x5e0<br>
&gt; &gt; [=C2=A0 310.373449]=C2=A0 sock_sendmsg+0xba/0xf0<br>
&gt; &gt; [=C2=A0 310.374217]=C2=A0 sock_write_iter+0x2e4/0x6a0<br>
&gt; &gt; [=C2=A0 310.375005]=C2=A0 ? core_sys_select+0x47d/0x780<br>
&gt; &gt; [=C2=A0 310.375822]=C2=A0 ? sock_sendmsg+0xf0/0xf0<br>
&gt; &gt; [=C2=A0 310.376607]=C2=A0 __vfs_write+0x4e0/0x960<br>
&gt; &gt; [=C2=A0 310.377463]=C2=A0 ? kvm_clock_get_cycles+0x1e/0x20<br>
&gt; &gt; [=C2=A0 310.378864]=C2=A0 ? __vfs_read+0x950/0x950<br>
&gt; &gt; [=C2=A0 310.380178]=C2=A0 ? rw_verify_area+0xbd/0x2b0<br>
&gt; &gt; [=C2=A0 310.381092]=C2=A0 vfs_write+0x155/0x4b0<br>
&gt; &gt; [=C2=A0 310.381877]=C2=A0 SyS_write+0xf7/0x240<br>
&gt; &gt; [=C2=A0 310.382616]=C2=A0 ? SyS_read+0x240/0x240<br>
&gt; &gt; [=C2=A0 310.383404]=C2=A0 ? SyS_read+0x240/0x240<br>
&gt; &gt; [=C2=A0 310.384159]=C2=A0 do_syscall_64+0x235/0x5b0<br>
&gt; &gt; [=C2=A0 310.384930]=C2=A0 ? trace_raw_output_sys_exit+0xf0<wbr>/0=
xf0<br>
&gt; &gt; [=C2=A0 310.385747]=C2=A0 ? syscall_return_slowpath+0x240/<wbr>0x=
240<br>
&gt; &gt; [=C2=A0 310.386564]=C2=A0 ? trace_do_page_fault+0xc4/0x3a0<br>
&gt; &gt; [=C2=A0 310.387424]=C2=A0 ? prepare_exit_to_usermode+0x124<wbr>/0=
x160<br>
&gt; &gt; [=C2=A0 310.388524]=C2=A0 ? perf_trace_sys_enter+0x1080/0x<wbr>10=
80<br>
&gt; &gt; [=C2=A0 310.389347]=C2=A0 entry_SYSCALL64_slow_path+0x25<wbr>/0x2=
5<br>
&gt; &gt; [=C2=A0 310.390164] RIP: 0033:0x7f301f83c070<br>
&gt; &gt; [=C2=A0 310.390906] RSP: 002b:00007ffff738fc78 EFLAGS: 00000246 O=
RIG_RAX:<br>
&gt; &gt; 0000000000000001<br>
&gt; &gt; [=C2=A0 310.391943] RAX: ffffffffffffffda RBX: 0000000000000564 R=
CX:<br>
&gt; &gt; 00007f301f83c070<br>
&gt; &gt; [=C2=A0 310.392938] RDX: 0000000000000564 RSI: 000055cf87fb0748 R=
DI:<br>
&gt; &gt; 0000000000000003<br>
&gt; &gt; [=C2=A0 310.393947] RBP: 000055cf87f8f090 R08: 0000000000000000 R=
09:<br>
&gt; &gt; 0000000000003000<br>
&gt; &gt; [=C2=A0 310.394948] R10: 0000000000000008 R11: 0000000000000246 R=
12:<br>
&gt; &gt; 0000000000000000<br>
&gt; &gt; [=C2=A0 310.395967] R13: 00007ffff738fd0f R14: 000055cf873dde31 R=
15:<br>
&gt; &gt; 0000000000000003<br>
&gt; &gt; [=C2=A0 310.396969] Code: 00 00 48 89 5d d0 31 db 80 3c 02 00 0f =
85 05 02 00 00<br>
&gt; &gt; 49 8b 45 00 48 ba 00 00 00 00 00 fc ff df 48 8d 78 20 48 89 f9 48=
 c1 e9 03<br>
&gt; &gt; &lt;80&gt; 3c 11 00 0f 85 04 02 00 00 48 8b 58 20 48 ba 00 00 00 =
00 00<br>
&gt; &gt; [=C2=A0 310.399937] RIP: free_old_xmit_skbs.isra.29+0x9<wbr>d/0x2=
e0 [virtio_net] RSP:<br>
&gt; &gt; ffff880069e46540<br>
&gt; &gt; [=C2=A0 310.401120] ---[ end trace 89c5b0ea3f07debe ]---<br>
&gt; &gt; [=C2=A0 310.403923] Kernel panic - not syncing: Fatal exception i=
n interrupt<br>
&gt; &gt; [=C2=A0 310.405942] Kernel Offset: 0x33200000 from 0xffffffff8100=
0000 (relocation<br>
&gt; &gt; range: 0xffffffff80000000-0xffffffffb<wbr>fffffff)<br>
&gt; &gt; [=C2=A0 310.408133] ---[ end Kernel panic - not syncing: Fatal ex=
ception in<br>
&gt; &gt; interrupt<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; (gdb) l *(free_old_xmit_skbs+0x2b7)<br>
&gt; &gt; 0x22f7 is in free_old_xmit_skbs (drivers/net/virtio_net.c:1051<wb=
r>).<br>
&gt; &gt; 1046<br>
&gt; &gt; 1047=C2=A0 =C2=A0 =C2=A0 =C2=A0 static void free_old_xmit_skbs(st=
ruct send_queue *sq)<br>
&gt; &gt; 1048=C2=A0 =C2=A0 =C2=A0 =C2=A0 {<br>
&gt; &gt; 1049=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struc=
t sk_buff *skb;<br>
&gt; &gt; 1050=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsig=
ned int len;<br>
&gt; &gt; 1051=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struc=
t virtnet_info *vi =3D sq-&gt;vq-&gt;vdev-&gt;priv;<br>
&gt; &gt; 1052=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struc=
t virtnet_stats *stats =3D this_cpu_ptr(vi-&gt;stats);<br>
&gt; &gt; 1053=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsig=
ned int packets =3D 0;<br>
&gt; &gt; 1054=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsig=
ned int bytes =3D 0;<br>
&gt; &gt; 1055<br>
&gt; &gt;<br>
&gt; &gt; Let me know if i need to provide more informations.<br>
&gt; &gt;<br>
&gt; &gt; Best regards.<br>
&gt; &gt;<br>
&gt; &gt; Jean-Philippe<br>
&gt;<br>
&gt; So del_vq done during xdp setup seems to race with regular xmit.<br>
&gt;<br>
&gt; Since commit 680557cf79f82623e2c4fd42733077<wbr>d60a843513<br>
&gt;=C2=A0 =C2=A0 =C2=A0virtio_net: rework mergeable buffer handling<br>
&gt;<br>
&gt; we no longer must do the resets, we now have enough space<br>
&gt; to store a bit saying whether a buffer is xdp one or not.<br>
&gt;<br>
&gt; And that&#39;s probably a cleaner way to fix these issues than<br>
&gt; try to find and fix the race condition.<br>
&gt;<br>
&gt; John?<br>
&gt;<br>
&gt; --<br>
&gt; MST<br>
<br>
<br>
</div></div>I think I see the source of the race. virtio net calls<br>
netif_device_detach and assumes no packets will be sent after<br>
this point. However, all it does is stop all queues so<br>
no new packets will be transmitted.<br>
<br>
Try locking with HARD_TX_LOCK?<br>
<span class=3D"gmail-m_7376334747779054513gmail-m_7718901651756234020gmail-=
HOEnZb"><font color=3D"#888888"><br>
<br>
--<br>
MST<br>
</font></span></blockquote></div><br></div><div class=3D"gmail_extra">Hi Mi=
chael,<br><br></div><div class=3D"gmail_extra">from what i see, the race ap=
pear when we hit virtnet_reset in virtnet_xdp_set.<br></div><div class=3D"g=
mail_extra">virtnet_reset<br></div><div class=3D"gmail_extra">=C2=A0 _remov=
e_vq_common<br>=C2=A0=C2=A0=C2=A0 virtnet_del_vqs<br>=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 virtnet_free_queues<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0 kfre=
e(vi-&gt;sq)<br></div><div class=3D"gmail_extra">when the xdp program (with=
 two instances of the program to trigger it faster) is added or removed.<br=
><br></div><div class=3D"gmail_extra">It&#39;s easily repeatable, with 2 cp=
us and 4 queues on the qemu command line, running the xdp_ttl tool from Jes=
per.<br><br></div><div class=3D"gmail_extra">For now, i&#39;m able to conti=
nue my qualification, testing if xdp_qp is not null, but do not seem to be =
a sustainable trick.<br></div><div class=3D"gmail_extra">if (xdp_qp &amp;&a=
mp; vi-&gt;xdp_queues_pairs !=3D xdp_qp)<br><br></div><div class=3D"gmail_e=
xtra">Maybe it will be more clear to you with theses informations.<br><br><=
/div><div class=3D"gmail_extra">Best regards.<br><br></div><div class=3D"gm=
ail_extra">Jean-Philippe<br></div></div>

--001a11498f001909d50552866b18--

--===============2957328232076437393==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============2957328232076437393==--
