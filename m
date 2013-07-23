From: Borislav Petkov <bp@alien8.de>
Subject: Re: [BUG] [skge] WARNING: at lib/dma-debug.c:937
Date: Tue, 23 Jul 2013 14:36:24 +0200
Message-ID: <20130723123624.GA9063@pd.tnic>
References: <51EE76AC.3030908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: poma <pomidorabelisima@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51EE76AC.3030908@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding some relevant parties to CC.

On Tue, Jul 23, 2013 at 02:27:24PM +0200, poma wrote:
>=20
> Given much time is here, almost like a giraffe.
>=20
> 3.10.2:
> =E2=80=A6
> skge 0000:01:09.0 enp1s9: Link is up at 1000 Mbps, full duplex, flow
> control both
> ------------[ cut here ]------------
> WARNING: at lib/dma-debug.c:937 check_unmap+0x47b/0x930()
> skge 0000:01:09.0: DMA-API: device driver failed to check map
> error[device address=3D0x000000012175cec2] [size=3D42 bytes] [mapped =
as single]
> Modules linked in:
>  skge raid1 nouveau video mxm_wmi i2c_algo_bit drm_kms_helper ttm drm
> i2c_core wmi
> CPU: 3 PID: 0 Comm: swapper/3 Not tainted 3.10.2-301.fc19.x86_64.debu=
g #1
> Hardware name: Gigabyte Technology Co., Ltd. M720-US3/M720-US3, BIOS =
=467n
> 09/07/2010
>  0000000000000009 ffff88012ac03c58 ffffffff81717f12 ffff88012ac03c90
>  ffffffff810674d1 ffff880128330ac0 ffff880124f83ae8 ffffffff82bd7290
>  0000000000000282 ffffffff819f7ab3 ffff88012ac03cf0 ffffffff8106753c
> Call Trace:
>  <IRQ>  [<ffffffff81717f12>] dump_stack+0x19/0x1b
>  [<ffffffff810674d1>] warn_slowpath_common+0x61/0x80
>  [<ffffffff8106753c>] warn_slowpath_fmt+0x4c/0x50
>  [<ffffffff8137641b>] check_unmap+0x47b/0x930
>  [<ffffffff8137692f>] debug_dma_unmap_page+0x5f/0x70
>  [<ffffffffa01c6d35>] skge_poll+0xe5/0x9d0 [skge]
>  [<ffffffff815d8f61>] ? net_rx_action+0xa1/0x380
>  [<ffffffff815d9032>] net_rx_action+0x172/0x380
>  [<ffffffff81071817>] __do_softirq+0x107/0x410
>  [<ffffffff81071cf5>] irq_exit+0xc5/0xd0
>  [<ffffffff8172b6d6>] do_IRQ+0x56/0xc0
>  [<ffffffff81720772>] common_interrupt+0x72/0x72
>  <EOI>  [<ffffffff810494c6>] ? native_safe_halt+0x6/0x10
>  [<ffffffff81020ab4>] default_idle+0x24/0x270
>  [<ffffffff81020d7a>] amd_e400_idle+0x7a/0x110
>  [<ffffffff810215de>] arch_cpu_idle+0x2e/0x40
>  [<ffffffff810c93e2>] cpu_startup_entry+0xd2/0x410
>  [<ffffffff8170b158>] start_secondary+0x262/0x264
> ---[ end trace 80d48b7d4f24ac81 ]---
> Mapped at:
>  [<ffffffff81375251>] debug_dma_map_page+0x91/0x140
>  [<ffffffffa01c4140>] skge_xmit_frame+0x180/0x5d0 [skge]
>  [<ffffffff815da841>] dev_hard_start_xmit+0x301/0x6d0
>  [<ffffffff815fd20e>] sch_direct_xmit+0xee/0x290
>  [<ffffffff815dae88>] dev_queue_xmit+0x278/0x990
> =E2=80=A6
>=20
>=20
> 3.11-rc2:
> =E2=80=A6
> skge 0000:01:09.0 enp1s9: Link is up at 1000 Mbps, full duplex, flow
> control both
> ------------[ cut here ]------------
> WARNING: at lib/dma-debug.c:937 check_unmap+0x47b/0x930()
> skge 0000:01:09.0: DMA-API: device driver failed to check map
> error[device address=3D0x00000000cd3ae902] [size=3D42 bytes] [mapped =
as single]
> Modules linked in:
>  skge raid1 nouveau video mxm_wmi i2c_algo_bit drm_kms_helper ttm drm
> i2c_core wmi
> CPU: 3 PID: 1784 Comm: setroubleshootd Not tainted
> 3.11.0-0.rc2.git0.1.fc20.x86_64.debug #1
> Hardware name: Gigabyte Technology Co., Ltd. M720-US3/M720-US3, BIOS =
=467n
> 09/07/2010
>  0000000000000009 ffff88012ac03c58 ffffffff8172eeab ffff88012ac03ca0
>  ffff88012ac03c90 ffffffff810744fd ffff880128353ae0 ffff880124f48a28
>  ffffffff82bd3c10 0000000000000282 ffffffff81a03c03 ffff88012ac03cf0
> Call Trace:
>  <IRQ>  [<ffffffff8172eeab>] dump_stack+0x54/0x74
>  [<ffffffff810744fd>] warn_slowpath_common+0x7d/0xa0
>  [<ffffffff8107456c>] warn_slowpath_fmt+0x4c/0x50
>  [<ffffffff813943bb>] check_unmap+0x47b/0x930
>  [<ffffffff810e90bd>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff813948cf>] debug_dma_unmap_page+0x5f/0x70
>  [<ffffffffa01bdd35>] skge_poll+0xe5/0x9d0 [skge]
>  [<ffffffff815f9071>] ? net_rx_action+0xa1/0x380
>  [<ffffffff815f9142>] net_rx_action+0x172/0x380
>  [<ffffffff8107ef77>] __do_softirq+0x107/0x410
>  [<ffffffff8107f455>] irq_exit+0xc5/0xd0
>  [<ffffffff81744596>] do_IRQ+0x56/0xc0
>  [<ffffffff81738c72>] common_interrupt+0x72/0x72
>  <EOI>  [<ffffffff81181583>] ? get_page_from_freelist+0x533/0x9a0
>  [<ffffffff81021899>] ? sched_clock+0x9/0x10
>  [<ffffffff81021899>] ? sched_clock+0x9/0x10
>  [<ffffffff81181bc3>] __alloc_pages_nodemask+0x1d3/0xbe0
>  [<ffffffff81021825>] ? native_sched_clock+0x15/0x80
>  [<ffffffff81021899>] ? sched_clock+0x9/0x10
>  [<ffffffff810e96d5>] ? __lock_acquire+0x2e5/0x1b10
>  [<ffffffff810e5ed7>] ? __lock_is_held+0x57/0x80
>  [<ffffffff811c660a>] alloc_pages_vma+0x9a/0x140
>  [<ffffffff811a4b6b>] handle_pte_fault+0x6ab/0x990
>  [<ffffffff811a5c95>] handle_mm_fault+0x2a5/0x5c0
>  [<ffffffff8173ccb2>] __do_page_fault+0x162/0x5a0
>  [<ffffffff810e8fed>] ? trace_hardirqs_on_caller+0xfd/0x1c0
>  [<ffffffff810e90bd>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff8173803c>] ? _raw_spin_unlock_irq+0x2c/0x50
>  [<ffffffff810b04dc>] ? finish_task_switch+0x7c/0x120
>  [<ffffffff810b049f>] ? finish_task_switch+0x3f/0x120
>  [<ffffffff81738d18>] ? retint_swapgs+0x13/0x1b
>  [<ffffffff8137c02d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff8173d0fe>] do_page_fault+0xe/0x10
>  [<ffffffff81739008>] page_fault+0x28/0x30
> ---[ end trace aba61fbe029924e7 ]---
> Mapped at:
>  [<ffffffff813931f1>] debug_dma_map_page+0x91/0x140
>  [<ffffffffa01bb140>] skge_xmit_frame+0x180/0x5d0 [skge]
>  [<ffffffff815fb1b1>] dev_hard_start_xmit+0x301/0x6d0
>  [<ffffffff8161deae>] sch_direct_xmit+0xee/0x290
>  [<ffffffff815fb7fb>] dev_queue_xmit+0x27b/0x990
> =E2=80=A6
>=20
>=20
> poma
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

--=20
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
