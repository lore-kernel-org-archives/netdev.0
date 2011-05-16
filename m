From: Stefan Majer <stefan.majer@gmail.com>
Subject: Re: Kernel 2.6.38.6 page allocation failure (ixgbe)
Date: Mon, 16 May 2011 10:28:17 +0200
Message-ID: <BANLkTikVvbk5QqCLBv7KfwiAKedEWadkbQ@mail.gmail.com>
References: <BANLkTinr34qmAE8RWVY0Wq_XMfOc0jTUzg@mail.gmail.com>
	<BANLkTik=FM5LJs8JUKHR2S+r41vi94Z7pw@mail.gmail.com>
	<F169D4F5E1F1974DBFAFABF47F60C10AF23DC8FF@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10AF23DC8FF@orsmsx507.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

after enlarging vm.min_free_kbytes to 524288 we survived almost a
week, but today i got this again:

May 16 09:18:13 os03 kernel: [331036.332001] kworker/0:1: page
allocation failure. order:2, mode:0x4020
May 16 09:18:13 os03 kernel: [331036.332005] Pid: 0, comm: kworker/0:1
Tainted: P        W   2.6.38.6-1.fits.3.el6.x86_64 #1
May 16 09:18:13 os03 kernel: [331036.332009] Call Trace:
May 16 09:18:13 os03 kernel: [331036.332011]  <IRQ>
[<ffffffff81108ce7>] ? __alloc_pages_nodemask+0x6f7/0x8a0
May 16 09:18:13 os03 kernel: [331036.332024]  [<ffffffff81146cd2>] ?
kmalloc_large_node+0x62/0xb0
May 16 09:18:13 os03 kernel: [331036.332028]  [<ffffffff8114becb>] ?
__kmalloc_node_track_caller+0x15b/0x1d0
May 16 09:18:13 os03 kernel: [331036.332033]  [<ffffffff814b06ed>] ?
ip_rcv+0x23d/0x310
May 16 09:18:13 os03 kernel: [331036.332038]  [<ffffffff81466f74>] ?
__netdev_alloc_skb+0x24/0x50
May 16 09:18:13 os03 kernel: [331036.332042]  [<ffffffff81466713>] ?
__alloc_skb+0x83/0x170
May 16 09:18:13 os03 kernel: [331036.332045]  [<ffffffff81466f74>] ?
__netdev_alloc_skb+0x24/0x50
May 16 09:18:13 os03 kernel: [331036.332054]  [<ffffffffa0170217>] ?
ixgbe_alloc_rx_buffers+0x2b7/0x370 [ixgbe]
May 16 09:18:13 os03 kernel: [331036.332059]  [<ffffffff8108d29d>] ?
sched_clock_cpu+0xcd/0x110
May 16 09:18:13 os03 kernel: [331036.332063]  [<ffffffff81474840>] ?
napi_skb_finish+0x50/0x70
May 16 09:18:13 os03 kernel: [331036.332069]  [<ffffffffa0172678>] ?
ixgbe_clean_rx_irq+0x828/0x890 [ixgbe]
May 16 09:18:13 os03 kernel: [331036.332076]  [<ffffffffa01747cf>] ?
ixgbe_clean_rxtx_many+0x10f/0x220 [ixgbe]
May 16 09:18:13 os03 kernel: [331036.332080]  [<ffffffff81474eb2>] ?
net_rx_action+0x102/0x2a0
May 16 09:18:13 os03 kernel: [331036.332084]  [<ffffffff8106b745>] ?
__do_softirq+0xb5/0x210
May 16 09:18:13 os03 kernel: [331036.332089]  [<ffffffff810c7ca4>] ?
handle_IRQ_event+0x54/0x180
May 16 09:18:13 os03 kernel: [331036.332094]  [<ffffffff8100cf3c>] ?
call_softirq+0x1c/0x30
May 16 09:18:13 os03 kernel: [331036.332097]  [<ffffffff8100e975>] ?
do_softirq+0x65/0xa0
May 16 09:18:13 os03 kernel: [331036.332100]  [<ffffffff8106b605>] ?
irq_exit+0x95/0xa0
May 16 09:18:13 os03 kernel: [331036.332105]  [<ffffffff8154a276>] ?
do_IRQ+0x66/0xe0
May 16 09:18:13 os03 kernel: [331036.332108]  [<ffffffff81542a53>] ?
ret_from_intr+0x0/0x15
May 16 09:18:13 os03 kernel: [331036.332110]  <EOI>
[<ffffffff812db311>] ? intel_idle+0xc1/0x120
May 16 09:18:13 os03 kernel: [331036.332116]  [<ffffffff812db2f4>] ?
intel_idle+0xa4/0x120
May 16 09:18:13 os03 kernel: [331036.332121]  [<ffffffff8143bca5>] ?
cpuidle_idle_call+0xb5/0x240
May 16 09:18:13 os03 kernel: [331036.332125]  [<ffffffff8100aa87>] ?
cpu_idle+0xb7/0x110
May 16 09:18:13 os03 kernel: [331036.332129]  [<ffffffff81538ffe>] ?
start_secondary+0x21f/0x221
May 16 09:18:13 os03 kernel: [331036.332131] Mem-Info:
May 16 09:18:13 os03 kernel: [331036.332132] Node 0 DMA per-cpu:
May 16 09:18:13 os03 kernel: [331036.332135] CPU    0: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332137] CPU    1: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332140] CPU    2: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332142] CPU    3: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332144] CPU    4: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332146] CPU    5: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332148] CPU    6: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332150] CPU    7: hi:    0, btch:
  1 usd:   0
May 16 09:18:13 os03 kernel: [331036.332152] Node 0 DMA32 per-cpu:
May 16 09:18:13 os03 kernel: [331036.332155] CPU    0: hi:  186, btch:
 31 usd: 163
May 16 09:18:13 os03 kernel: [331036.332157] CPU    1: hi:  186, btch:
 31 usd:  31
May 16 09:18:13 os03 kernel: [331036.332159] CPU    2: hi:  186, btch:
 31 usd: 182
May 16 09:18:13 os03 kernel: [331036.332162] CPU    3: hi:  186, btch:
 31 usd:  37
May 16 09:18:13 os03 kernel: [331036.332164] CPU    4: hi:  186, btch:
 31 usd:  13
May 16 09:18:13 os03 kernel: [331036.332166] CPU    5: hi:  186, btch:
 31 usd: 180
May 16 09:18:13 os03 kernel: [331036.332168] CPU    6: hi:  186, btch:
 31 usd: 159
May 16 09:18:13 os03 kernel: [331036.332170] CPU    7: hi:  186, btch:
 31 usd: 180
May 16 09:18:13 os03 kernel: [331036.332172] Node 0 Normal per-cpu:
May 16 09:18:13 os03 kernel: [331036.332174] CPU    0: hi:  186, btch:
 31 usd: 156
May 16 09:18:13 os03 kernel: [331036.332177] CPU    1: hi:  186, btch:
 31 usd: 160
May 16 09:18:13 os03 kernel: [331036.332179] CPU    2: hi:  186, btch:
 31 usd: 163
May 16 09:18:13 os03 kernel: [331036.332181] CPU    3: hi:  186, btch:
 31 usd: 168
May 16 09:18:13 os03 kernel: [331036.332183] CPU    4: hi:  186, btch:
 31 usd: 163
May 16 09:18:13 os03 kernel: [331036.332185] CPU    5: hi:  186, btch:
 31 usd: 180
May 16 09:18:13 os03 kernel: [331036.332187] CPU    6: hi:  186, btch:
 31 usd: 156
May 16 09:18:13 os03 kernel: [331036.332189] CPU    7: hi:  186, btch:
 31 usd: 182
May 16 09:18:13 os03 kernel: [331036.332195] active_anon:389538
inactive_anon:91572 isolated_anon:0
May 16 09:18:13 os03 kernel: [331036.332196]  active_file:2597361
inactive_file:2476894 isolated_file:0
May 16 09:18:13 os03 kernel: [331036.332198]  unevictable:123699
dirty:66164 writeback:11426 unstable:0
May 16 09:18:13 os03 kernel: [331036.332199]  free:254614
slab_reclaimable:53393 slab_unreclaimable:15304
May 16 09:18:13 os03 kernel: [331036.332201]  mapped:1251 shmem:91580
pagetables:1404 bounce:0
May 16 09:18:13 os03 kernel: [331036.332203] Node 0 DMA free:15852kB
min:328kB low:408kB high:492kB active_anon:0kB inactive_anon:0kB
active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
May 16 09:18:13 os03 kernel: [331036.332214] lowmem_reserve[]: 0 2991
24201 24201
May 16 09:18:13 os03 kernel: [331036.332217] Node 0 DMA32
free:426948kB min:64764kB low:80952kB high:97144kB
active_anon:135484kB inactive_anon:0kB active_file:1133516kB
inactive_file:1093352kB unevictable:49788kB isolated(anon):0kB
isolated(file):0kB present:3063392kB mlocked:0kB dirty:110436kB
writeback:284kB mapped:432kB shmem:0kB slab_reclaimable:46680kB
slab_unreclaimable:5268kB kernel_stack:152kB pagetables:324kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
May 16 09:18:13 os03 kernel: [331036.332229] lowmem_reserve[]: 0 0 21210 21=
210
May 16 09:18:13 os03 kernel: [331036.332232] Node 0 Normal
free:575656kB min:459188kB low:573984kB high:688780kB
active_anon:1422668kB inactive_anon:366288kB active_file:9255928kB
inactive_file:8814224kB unevictable:445008kB isolated(anon):0kB
isolated(file):0kB present:21719040kB mlocked:0kB dirty:154220kB
writeback:45420kB mapped:4572kB shmem:366320kB
slab_reclaimable:166892kB slab_unreclaimable:55948kB
kernel_stack:3928kB pagetables:5292kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
May 16 09:18:13 os03 kernel: [331036.332245] lowmem_reserve[]: 0 0 0 0
May 16 09:18:13 os03 kernel: [331036.332248] Node 0 DMA: 1*4kB 1*8kB
0*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB
3*4096kB =3D 15852kB
May 16 09:18:13 os03 kernel: [331036.332256] Node 0 DMA32: 55808*4kB
24890*8kB 3*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 1*4096kB =3D 426496kB
May 16 09:18:13 os03 kernel: [331036.332264] Node 0 Normal: 142372*4kB
49*8kB 67*16kB 48*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 1*4096kB =3D 576648kB
May 16 09:18:13 os03 kernel: [331036.332272] 5289868 total pagecache pages
May 16 09:18:13 os03 kernel: [331036.332274] 0 pages in swap cache


Is there any way to further identify which is causing this bug? Any
help appreciated.

Greetings Stefan

On Tue, May 10, 2011 at 9:06 PM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
> Adding e1000-devel, our list for the out-of-tree ixgbe driver (the issue =
is reported below to be in both upstream and out-of-tree)
>
> do you have jumbo frames enabled?
>
> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] =
On Behalf Of Stefan Majer
> Sent: Tuesday, May 10, 2011 9:03 AM
> To: netdev@vger.kernel.org
> Subject: Kernel 2.6.38.6 page allocation failure (ixgbe)
>
> Hi,
>
> im running 4 nodes with ceph on top of btrfs with a dualport Intel
> X520 10Gb Ethernet Card with the latest 3.3.9 ixgbe driver.
> during benchmarks i get the following stack.
> I can easily reproduce this by simply running rados bench from a fast
> machine using this 4 nodes as ceph cluster.
> We saw this with stock ixgbe driver from 2.6.38.6 and with the latest
> 3.3.9 ixgbe.
> This kernel is tainted because we use fusion-io iodrives as journal
> devices for btrfs.
>
> Any hints to nail this down are welcome.
>
> Greetings Stefan Majer
>
> May 10 15:26:40 os02 kernel: [ 3652.485219] cosd: page allocation
> failure. order:2, mode:0x4020
> May 10 15:26:40 os02 kernel: [ 3652.485223] kswapd0: page allocation
> failure. order:2, mode:0x4020
> May 10 15:26:40 os02 kernel: [ 3652.485228] Pid: 57, comm: kswapd0
> Tainted: P =A0 =A0 =A0 =A0W =A0 2.6.38.6-1.fits.1.el6.x86_64 #1
> May 10 15:26:40 os02 kernel: [ 3652.485230] Call Trace:
> May 10 15:26:40 os02 kernel: [ 3652.485232] =A0<IRQ>
> [<ffffffff81108ce7>] ? __alloc_pages_nodemask+0x6f7/0x8a0
> May 10 15:26:40 os02 kernel: [ 3652.485247] =A0[<ffffffff814b0ad0>] ?
> ip_local_deliver+0x80/0x90
> May 10 15:26:40 os02 kernel: [ 3652.485250] cosd: page allocation
> failure. order:2, mode:0x4020
> May 10 15:26:40 os02 kernel: [ 3652.485256] =A0[<ffffffff81146cd2>] ?
> kmalloc_large_node+0x62/0xb0
> May 10 15:26:40 os02 kernel: [ 3652.485259] Pid: 1849, comm: cosd
> Tainted: P =A0 =A0 =A0 =A0W =A0 2.6.38.6-1.fits.1.el6.x86_64 #1
> May 10 15:26:40 os02 kernel: [ 3652.485261] Call Trace:
> May 10 15:26:40 os02 kernel: [ 3652.485264] =A0[<ffffffff8114becb>] ?
> __kmalloc_node_track_caller+0x15b/0x1d0
> May 10 15:26:40 os02 kernel: [ 3652.485266] =A0<IRQ>
> [<ffffffff81466f74>] ? __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3652.485274] =A0[<ffffffff81108ce7>] ?
> __alloc_pages_nodemask+0x6f7/0x8a0
> May 10 15:26:40 os02 kernel: [ 3652.485277] =A0[<ffffffff81466713>] ?
> __alloc_skb+0x83/0x170
> May 10 15:26:40 os02 kernel: [ 3652.485281] =A0[<ffffffff814b0ad0>] ?
> ip_local_deliver+0x80/0x90
> May 10 15:26:40 os02 kernel: [ 3652.485283] =A0[<ffffffff81466f74>] ?
> __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3652.485287] =A0[<ffffffff81146cd2>] ?
> kmalloc_large_node+0x62/0xb0
> May 10 15:26:40 os02 kernel: [ 3652.485297] =A0[<ffffffffa005d9aa>] ?
> ixgbe_alloc_rx_buffers+0x9a/0x450 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3652.485300] =A0[<ffffffff8114becb>] ?
> __kmalloc_node_track_caller+0x15b/0x1d0
> May 10 15:26:40 os02 kernel: [ 3652.485305] =A0[<ffffffff812b79e0>] ?
> swiotlb_map_page+0x0/0x110
> May 10 15:26:40 os02 kernel: [ 3652.485308] =A0[<ffffffff81466f74>] ?
> __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3652.485315] =A0[<ffffffffa0060930>] ?
> ixgbe_poll+0x1140/0x1670 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3652.485318] =A0[<ffffffff81466713>] ?
> __alloc_skb+0x83/0x170
> May 10 15:26:40 os02 kernel: [ 3652.485323] =A0[<ffffffff810f33eb>] ?
> perf_pmu_enable+0x2b/0x40
> May 10 15:26:40 os02 kernel: [ 3652.485326] =A0[<ffffffff81466f74>] ?
> __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3652.485330] =A0[<ffffffff81474eb2>] ?
> net_rx_action+0x102/0x2a0
> May 10 15:26:40 os02 kernel: [ 3652.485336] =A0[<ffffffffa005d9aa>] ?
> ixgbe_alloc_rx_buffers+0x9a/0x450 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3652.485341] =A0[<ffffffff8106b745>] ?
> __do_softirq+0xb5/0x210
> May 10 15:26:40 os02 kernel: [ 3652.485344] =A0[<ffffffff81474840>] ?
> napi_skb_finish+0x50/0x70
> May 10 15:26:40 os02 kernel: [ 3652.485348] =A0[<ffffffff810c7ca4>] ?
> handle_IRQ_event+0x54/0x180
> May 10 15:26:40 os02 kernel: [ 3652.485354] =A0[<ffffffffa0060930>] ?
> ixgbe_poll+0x1140/0x1670 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3652.485357] =A0[<ffffffff8106b7bd>] ?
> __do_softirq+0x12d/0x210
> May 10 15:26:40 os02 kernel: [ 3652.485360] =A0[<ffffffff810f33eb>] ?
> perf_pmu_enable+0x2b/0x40
> May 10 15:26:40 os02 kernel: [ 3652.485364] =A0[<ffffffff8100cf3c>] ?
> call_softirq+0x1c/0x30
> May 10 15:26:40 os02 kernel: [ 3652.485367] =A0[<ffffffff81474eb2>] ?
> net_rx_action+0x102/0x2a0
> May 10 15:26:40 os02 kernel: [ 3652.485369] =A0[<ffffffff8100e975>] ?
> do_softirq+0x65/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.485372] =A0[<ffffffff8106b745>] ?
> __do_softirq+0xb5/0x210
> May 10 15:26:40 os02 kernel: [ 3652.485375] =A0[<ffffffff8106b605>] ?
> irq_exit+0x95/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.485379] =A0[<ffffffff810c7ca4>] ?
> handle_IRQ_event+0x54/0x180
> May 10 15:26:40 os02 kernel: [ 3652.485383] =A0[<ffffffff8154a276>] ?
> do_IRQ+0x66/0xe0
> May 10 15:26:40 os02 kernel: [ 3652.485386] =A0[<ffffffff8106b7bd>] ?
> __do_softirq+0x12d/0x210
> May 10 15:26:40 os02 kernel: [ 3652.485389] =A0[<ffffffff81542a53>] ?
> ret_from_intr+0x0/0x15
> May 10 15:26:40 os02 kernel: [ 3652.485391] =A0<EOI>
> [<ffffffff8100cf3c>] ? call_softirq+0x1c/0x30
> May 10 15:26:40 os02 kernel: [ 3652.485397] =A0[<ffffffff81110a54>] ?
> shrink_inactive_list+0x164/0x460
> May 10 15:26:40 os02 kernel: [ 3652.485400] =A0[<ffffffff8100e975>] ?
> do_softirq+0x65/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.485404] =A0[<ffffffff8153facc>] ?
> schedule+0x44c/0xa10
> May 10 15:26:40 os02 kernel: [ 3652.485407] =A0[<ffffffff8106b605>] ?
> irq_exit+0x95/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.485412] =A0[<ffffffff81109b1a>] ?
> determine_dirtyable_memory+0x1a/0x30
> May 10 15:26:40 os02 kernel: [ 3652.485416] =A0[<ffffffff8154a276>] ?
> do_IRQ+0x66/0xe0
> May 10 15:26:40 os02 kernel: [ 3652.485419] =A0[<ffffffff81111453>] ?
> shrink_zone+0x3d3/0x530
> May 10 15:26:40 os02 kernel: [ 3652.485422] =A0[<ffffffff81542a53>] ?
> ret_from_intr+0x0/0x15
> May 10 15:26:40 os02 kernel: [ 3652.485423] =A0<EOI>
> [<ffffffff81074a4a>] ? del_timer_sync+0x3a/0x60
> May 10 15:26:40 os02 kernel: [ 3652.485430] =A0[<ffffffff812a774d>] ?
> copy_user_generic_string+0x2d/0x40
> May 10 15:26:40 os02 kernel: [ 3652.485435] =A0[<ffffffff811054a5>] ?
> zone_watermark_ok_safe+0xb5/0xd0
> May 10 15:26:40 os02 kernel: [ 3652.485439] =A0[<ffffffff810ff351>] ?
> iov_iter_copy_from_user_atomic+0x101/0x170
> May 10 15:26:40 os02 kernel: [ 3652.485442] =A0[<ffffffff81112a69>] ?
> kswapd+0x889/0xb20
> May 10 15:26:40 os02 kernel: [ 3652.485457] =A0[<ffffffffa026c91d>] ?
> btrfs_copy_from_user+0xcd/0x130 [btrfs]
> May 10 15:26:40 os02 kernel: [ 3652.485460] =A0[<ffffffff811121e0>] ?
> kswapd+0x0/0xb20
> May 10 15:26:40 os02 kernel: [ 3652.485472] =A0[<ffffffffa026d844>] ?
> __btrfs_buffered_write+0x1a4/0x330 [btrfs]
> May 10 15:26:40 os02 kernel: [ 3652.485476] =A0[<ffffffff810862b6>] ?
> kthread+0x96/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.485479] =A0[<ffffffff8117151f>] ?
> file_update_time+0x5f/0x170
> May 10 15:26:40 os02 kernel: [ 3652.485482] =A0[<ffffffff8100ce44>] ?
> kernel_thread_helper+0x4/0x10
> May 10 15:26:40 os02 kernel: [ 3652.485493] =A0[<ffffffffa026dc08>] ?
> btrfs_file_aio_write+0x238/0x4e0 [btrfs]
> May 10 15:26:40 os02 kernel: [ 3652.485496] =A0[<ffffffff81086220>] ?
> kthread+0x0/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.485507] =A0[<ffffffffa026d9d0>] ?
> btrfs_file_aio_write+0x0/0x4e0 [btrfs]
> May 10 15:26:40 os02 kernel: [ 3652.485511] =A0[<ffffffff8100ce40>] ?
> kernel_thread_helper+0x0/0x10
> May 10 15:26:40 os02 kernel: [ 3652.485515] =A0[<ffffffff81158ff3>] ?
> do_sync_readv_writev+0xd3/0x110
> May 10 15:26:40 os02 kernel: [ 3652.485516] Mem-Info:
> May 10 15:26:40 os02 kernel: [ 3652.485519] =A0[<ffffffff81163d42>] ?
> path_put+0x22/0x30
> May 10 15:26:40 os02 kernel: [ 3652.485521] Node 0 DMA per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.485525] =A0[<ffffffff812584a3>] ?
> selinux_file_permission+0xf3/0x150
> May 10 15:26:40 os02 kernel: [ 3652.485528] CPU =A0 =A00: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485530] CPU =A0 =A01: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485534] =A0[<ffffffff81251583>] ?
> security_file_permission+0x23/0x90
> May 10 15:26:40 os02 kernel: [ 3652.485535] CPU =A0 =A02: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485538] CPU =A0 =A03: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485542] =A0[<ffffffff81159f14>] ?
> do_readv_writev+0xd4/0x1e0
> May 10 15:26:40 os02 kernel: [ 3652.485544] CPU =A0 =A04: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485547] CPU =A0 =A05: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485550] =A0[<ffffffff81540d91>] ?
> mutex_lock+0x31/0x60
> May 10 15:26:40 os02 kernel: [ 3652.485552] CPU =A0 =A06: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485554] CPU =A0 =A07: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485557] =A0[<ffffffff8115a066>] ?
> vfs_writev+0x46/0x60
> May 10 15:26:40 os02 kernel: [ 3652.485558] Node 0 DMA32 per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.485562] =A0[<ffffffff8115a1a1>] ?
> sys_writev+0x51/0xc0
> May 10 15:26:40 os02 kernel: [ 3652.485564] CPU =A0 =A00: hi: =A0186, btc=
h:
> 31 usd: 144
> May 10 15:26:40 os02 kernel: [ 3652.485567] CPU =A0 =A01: hi: =A0186, btc=
h:
> 31 usd: 198
> May 10 15:26:40 os02 kernel: [ 3652.485571] =A0[<ffffffff8100c002>] ?
> system_call_fastpath+0x16/0x1b
> May 10 15:26:40 os02 kernel: [ 3652.485573] CPU =A0 =A02: hi: =A0186, btc=
h:
> 31 usd: 180
> May 10 15:26:40 os02 kernel: [ 3652.485574] Mem-Info:
> May 10 15:26:40 os02 kernel: [ 3652.485576] CPU =A0 =A03: hi: =A0186, btc=
h:
> 31 usd: 171
> May 10 15:26:40 os02 kernel: [ 3652.485578] Node 0 CPU =A0 =A04: hi: =A01=
86,
> btch: =A031 usd: 159
> May 10 15:26:40 os02 kernel: [ 3652.485581] DMA per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.485582] CPU =A0 =A05: hi: =A0186, btc=
h:
> 31 usd: =A069
> May 10 15:26:40 os02 kernel: [ 3652.485585] CPU =A0 =A00: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485587] CPU =A0 =A06: hi: =A0186, btc=
h:
> 31 usd: 180
> May 10 15:26:40 os02 kernel: [ 3652.485589] CPU =A0 =A01: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485591] CPU =A0 =A07: hi: =A0186, btc=
h:
> 31 usd: 184
> May 10 15:26:40 os02 kernel: [ 3652.485593] CPU =A0 =A02: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485594] Node 0 CPU =A0 =A03: hi: =A0 =
=A00,
> btch: =A0 1 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485597] Normal per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.485598] CPU =A0 =A04: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485600] CPU =A0 =A00: hi: =A0186, btc=
h:
> 31 usd: 100
> May 10 15:26:40 os02 kernel: [ 3652.485602] CPU =A0 =A05: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485604] CPU =A0 =A01: hi: =A0186, btc=
h:
> 31 usd: =A047
> May 10 15:26:40 os02 kernel: [ 3652.485606] CPU =A0 =A06: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485608] CPU =A0 =A02: hi: =A0186, btc=
h:
> 31 usd: 168
> May 10 15:26:40 os02 kernel: [ 3652.485610] CPU =A0 =A07: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.485612] CPU =A0 =A03: hi: =A0186, btc=
h:
> 31 usd: 140
> May 10 15:26:40 os02 kernel: [ 3652.485614] Node 0 CPU =A0 =A04: hi: =A01=
86,
> btch: =A031 usd: 177
> May 10 15:26:40 os02 kernel: [ 3652.485617] DMA32 per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.485618] CPU =A0 =A05: hi: =A0186, btc=
h:
> 31 usd: =A077
> May 10 15:26:40 os02 kernel: [ 3652.485621] CPU =A0 =A00: hi: =A0186, btc=
h:
> 31 usd: 144
> May 10 15:26:40 os02 kernel: [ 3652.485623] CPU =A0 =A06: hi: =A0186, btc=
h:
> 31 usd: 168
> May 10 15:26:40 os02 kernel: [ 3652.485625] CPU =A0 =A01: hi: =A0186, btc=
h:
> 31 usd: 198
> May 10 15:26:40 os02 kernel: [ 3652.485627] CPU =A0 =A07: hi: =A0186, btc=
h:
> 31 usd: =A068
> May 10 15:26:40 os02 kernel: [ 3652.485629] CPU =A0 =A02: hi: =A0186, btc=
h:
> 31 usd: 180
> May 10 15:26:40 os02 kernel: [ 3652.485634] active_anon:255806
> inactive_anon:19454 isolated_anon:0
> May 10 15:26:40 os02 kernel: [ 3652.485636] =A0active_file:420093
> inactive_file:5180559 isolated_file:0
> May 10 15:26:40 os02 kernel: [ 3652.485637] =A0unevictable:50582
> dirty:314034 writeback:8484 unstable:0
> May 10 15:26:40 os02 kernel: [ 3652.485639] =A0free:30074
> slab_reclaimable:35739 slab_unreclaimable:13526
> May 10 15:26:40 os02 kernel: [ 3652.485641] =A0mapped:3440 shmem:51
> pagetables:1342 bounce:0
> May 10 15:26:40 os02 kernel: [ 3652.485643] CPU =A0 =A03: hi: =A0186, btc=
h:
> 31 usd: 171
> May 10 15:26:40 os02 kernel: [ 3652.485644] Node 0 CPU =A0 =A04: hi: =A01=
86,
> btch: =A031 usd: 159
> May 10 15:26:40 os02 kernel: [ 3652.485652] DMA free:15852kB min:12kB
> low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB
> inactive_file:0kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB
> mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
> kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> May 10 15:26:40 os02 kernel: [ 3652.485659] CPU =A0 =A05: hi: =A0186, btc=
h:
> 31 usd: =A069
> May 10 15:26:40 os02 kernel: [ 3652.485661] lowmem_reserve[]:CPU =A0 =A06:
> hi: =A0186, btch: =A031 usd: 180
> May 10 15:26:40 os02 kernel: [ 3652.485663] =A00CPU =A0 =A07: hi: =A0186,
> btch: =A031 usd: 184
> May 10 15:26:40 os02 kernel: [ 3652.485665] =A02991Node 0 =A024201Normal =
per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.485668] =A024201CPU =A0 =A00: hi: =A0=
186,
> btch: =A031 usd: 100
> May 10 15:26:40 os02 kernel: [ 3652.485671]
> May 10 15:26:40 os02 kernel: [ 3652.485672] CPU =A0 =A01: hi: =A0186, btc=
h:
> 31 usd: =A047
> May 10 15:26:40 os02 kernel: [ 3652.485674] Node 0 CPU =A0 =A02: hi: =A01=
86,
> btch: =A031 usd: 168
> May 10 15:26:40 os02 kernel: [ 3652.485682] DMA32 free:85748kB
> min:2460kB low:3072kB high:3688kB active_anon:20480kB
> inactive_anon:5268kB active_file:151588kB inactive_file:2645188kB
> unevictable:72kB isolated(anon):0kB isolated(file):0kB
> present:3063392kB mlocked:0kB dirty:210820kB writeback:0kB
> mapped:648kB shmem:0kB slab_reclaimable:28400kB
> slab_unreclaimable:2152kB kernel_stack:520kB pagetables:100kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> May 10 15:26:40 os02 kernel: [ 3652.485690] CPU =A0 =A03: hi: =A0186, btc=
h:
> 31 usd: 140
> May 10 15:26:40 os02 kernel: [ 3652.485691] lowmem_reserve[]:CPU =A0 =A04:
> hi: =A0186, btch: =A031 usd: 177
> May 10 15:26:40 os02 kernel: [ 3652.485693] =A00CPU =A0 =A05: hi: =A0186,
> btch: =A031 usd: =A077
> May 10 15:26:40 os02 kernel: [ 3652.485696] =A00CPU =A0 =A06: hi: =A0186,
> btch: =A031 usd: 168
> May 10 15:26:40 os02 kernel: [ 3652.485698] =A021210CPU =A0 =A07: hi: =A0=
186,
> btch: =A031 usd: =A068
> May 10 15:26:40 os02 kernel: [ 3652.485701] =A021210active_anon:255806
> inactive_anon:19454 isolated_anon:0
> May 10 15:26:40 os02 kernel: [ 3652.485705] =A0active_file:420093
> inactive_file:5180559 isolated_file:0
> May 10 15:26:40 os02 kernel: [ 3652.485706] =A0unevictable:50582
> dirty:314034 writeback:8484 unstable:0
> May 10 15:26:40 os02 kernel: [ 3652.485707] =A0free:30074
> slab_reclaimable:35739 slab_unreclaimable:13526
> May 10 15:26:40 os02 kernel: [ 3652.485708] =A0mapped:3440 shmem:51
> pagetables:1342 bounce:0
> May 10 15:26:40 os02 kernel: [ 3652.485709]
> May 10 15:26:40 os02 kernel: [ 3652.485710] Node 0 Node 0 DMA
> free:15852kB min:12kB low:12kB high:16kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:15660kB mlocked:0kB
> dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
> bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> May 10 15:26:40 os02 kernel: [ 3652.485724] Normal free:18696kB
> min:17440kB low:21800kB high:26160kB active_anon:1002744kB
> inactive_anon:72548kB active_file:1528784kB inactive_file:18077048kB
> unevictable:202256kB isolated(anon):0kB isolated(file):0kB
> present:21719040kB mlocked:0kB dirty:1045316kB writeback:33936kB
> mapped:13112kB shmem:204kB slab_reclaimable:114556kB
> slab_unreclaimable:51952kB kernel_stack:3768kB pagetables:5268kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32
> all_unreclaimable? no
> May 10 15:26:40 os02 kernel: [ 3652.485731]
> lowmem_reserve[]:lowmem_reserve[]: 0 0 2991 0 24201 0 24201 0
> May 10 15:26:40 os02 kernel: [ 3652.485737]
> May 10 15:26:40 os02 kernel: [ 3652.485738] Node 0 Node 0 DMA32
> free:85748kB min:2460kB low:3072kB high:3688kB active_anon:20480kB
> inactive_anon:5268kB active_file:151588kB inactive_file:2645188kB
> unevictable:72kB isolated(anon):0kB isolated(file):0kB
> present:3063392kB mlocked:0kB dirty:210820kB writeback:0kB
> mapped:648kB shmem:0kB slab_reclaimable:28400kB
> slab_unreclaimable:2152kB kernel_stack:520kB pagetables:100kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> May 10 15:26:40 os02 kernel: [ 3652.485747] DMA:
> lowmem_reserve[]:1*4kB =A001*8kB =A000*16kB =A0212101*32kB =A0212101*64kB
> May 10 15:26:40 os02 kernel: [ 3652.485754] 1*128kB Node 0 1*256kB
> Normal free:18696kB min:17440kB low:21800kB high:26160kB
> active_anon:1002744kB inactive_anon:72548kB active_file:1528784kB
> inactive_file:18077048kB unevictable:202256kB isolated(anon):0kB
> isolated(file):0kB present:21719040kB mlocked:0kB dirty:1045316kB
> writeback:33936kB mapped:13112kB shmem:204kB slab_reclaimable:114556kB
> slab_unreclaimable:51952kB kernel_stack:3768kB pagetables:5268kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32
> all_unreclaimable? no
> May 10 15:26:40 os02 kernel: [ 3652.485764] 0*512kB
> lowmem_reserve[]:1*1024kB =A001*2048kB =A003*4096kB =A00=3D 15852kB
> May 10 15:26:40 os02 kernel: [ 3652.485771] =A00Node 0
> May 10 15:26:40 os02 kernel: [ 3652.485773] DMA32: Node 0 59*4kB DMA:
> 125*8kB 1*4kB 66*16kB 1*8kB 80*32kB 0*16kB 188*64kB 1*32kB 51*128kB
> 1*64kB 15*256kB 1*128kB 40*512kB 1*256kB 31*1024kB 0*512kB 1*2048kB
> 1*1024kB 1*4096kB 1*2048kB =3D 85620kB
> May 10 15:26:40 os02 kernel: [ 3652.485789] 3*4096kB Node 0 =3D 15852kB
> May 10 15:26:40 os02 kernel: [ 3652.485791] Normal: Node 0 3930*4kB
> DMA32: 0*8kB 59*4kB 1*16kB 125*8kB 0*32kB 66*16kB 0*64kB 80*32kB
> 0*128kB 188*64kB 1*256kB 51*128kB 1*512kB 15*256kB 0*1024kB 40*512kB
> 1*2048kB 31*1024kB 0*4096kB 1*2048kB =3D 18552kB
> May 10 15:26:40 os02 kernel: [ 3652.485807] 1*4096kB 5651289 total
> pagecache pages
> May 10 15:26:40 os02 kernel: [ 3652.485809] =3D 85620kB
> May 10 15:26:40 os02 kernel: [ 3652.485810] 0 pages in swap cache
> May 10 15:26:40 os02 kernel: [ 3652.485811] Node 0 Swap cache stats:
> add 0, delete 0, find 0/0
> May 10 15:26:40 os02 kernel: [ 3652.485814] Normal: Free swap =A0=3D 1048=
572kB
> May 10 15:26:40 os02 kernel: [ 3652.485815] 3930*4kB Total swap =3D 10485=
72kB
> May 10 15:26:40 os02 kernel: [ 3652.485817] 0*8kB 1*16kB 0*32kB 0*64kB
> 0*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB =3D 18552kB
> May 10 15:26:40 os02 kernel: [ 3652.485822] 5651289 total pagecache pages
> May 10 15:26:40 os02 kernel: [ 3652.485823] 0 pages in swap cache
> May 10 15:26:40 os02 kernel: [ 3652.485824] Swap cache stats: add 0,
> delete 0, find 0/0
> May 10 15:26:40 os02 kernel: [ 3652.485825] Free swap =A0=3D 1048572kB
> May 10 15:26:40 os02 kernel: [ 3652.485826] Total swap =3D 1048572kB
> May 10 15:26:40 os02 kernel: [ 3652.486439] kworker/0:1: page
> allocation failure. order:2, mode:0x4020
> May 10 15:26:40 os02 kernel: [ 3652.486443] Pid: 0, comm: kworker/0:1
> Tainted: P =A0 =A0 =A0 =A0W =A0 2.6.38.6-1.fits.1.el6.x86_64 #1
> May 10 15:26:40 os02 kernel: [ 3652.486446] Call Trace:
> May 10 15:26:40 os02 kernel: [ 3652.486448] =A0<IRQ>
> [<ffffffff81108ce7>] ? __alloc_pages_nodemask+0x6f7/0x8a0
> May 10 15:26:40 os02 kernel: [ 3652.486459] =A0[<ffffffff814b0ad0>] ?
> ip_local_deliver+0x80/0x90
> May 10 15:26:40 os02 kernel: [ 3652.486464] =A0[<ffffffff81146cd2>] ?
> kmalloc_large_node+0x62/0xb0
> May 10 15:26:40 os02 kernel: [ 3652.486468] =A0[<ffffffff8114becb>] ?
> __kmalloc_node_track_caller+0x15b/0x1d0
> May 10 15:26:40 os02 kernel: [ 3652.486473] =A0[<ffffffff81466f74>] ?
> __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3652.486476] =A0[<ffffffff81466713>] ?
> __alloc_skb+0x83/0x170
> May 10 15:26:40 os02 kernel: [ 3652.486479] =A0[<ffffffff81466f74>] ?
> __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3652.486489] =A0[<ffffffffa005d9aa>] ?
> ixgbe_alloc_rx_buffers+0x9a/0x450 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3652.486494] =A0[<ffffffff81474840>] ?
> napi_skb_finish+0x50/0x70
> May 10 15:26:40 os02 kernel: [ 3652.486501] =A0[<ffffffffa0060930>] ?
> ixgbe_poll+0x1140/0x1670 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3652.486506] =A0[<ffffffff81013379>] ?
> sched_clock+0x9/0x10
> May 10 15:26:40 os02 kernel: [ 3652.486510] =A0[<ffffffff81474eb2>] ?
> net_rx_action+0x102/0x2a0
> May 10 15:26:40 os02 kernel: [ 3652.486514] =A0[<ffffffff8106b745>] ?
> __do_softirq+0xb5/0x210
> May 10 15:26:40 os02 kernel: [ 3652.486520] =A0[<ffffffff8108aec4>] ?
> hrtimer_interrupt+0x134/0x240
> May 10 15:26:40 os02 kernel: [ 3652.486523] =A0[<ffffffff8100cf3c>] ?
> call_softirq+0x1c/0x30
> May 10 15:26:40 os02 kernel: [ 3652.486526] =A0[<ffffffff8100e975>] ?
> do_softirq+0x65/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.486529] =A0[<ffffffff8106b605>] ?
> irq_exit+0x95/0xa0
> May 10 15:26:40 os02 kernel: [ 3652.486533] =A0[<ffffffff8154a360>] ?
> smp_apic_timer_interrupt+0x70/0x9b
> May 10 15:26:40 os02 kernel: [ 3652.486536] =A0[<ffffffff8100c9f3>] ?
> apic_timer_interrupt+0x13/0x20
> May 10 15:26:40 os02 kernel: [ 3652.486538] =A0<EOI>
> [<ffffffff812db311>] ? intel_idle+0xc1/0x120
> May 10 15:26:40 os02 kernel: [ 3652.486544] =A0[<ffffffff812db2f4>] ?
> intel_idle+0xa4/0x120
> May 10 15:26:40 os02 kernel: [ 3652.486549] =A0[<ffffffff8143bca5>] ?
> cpuidle_idle_call+0xb5/0x240
> May 10 15:26:40 os02 kernel: [ 3652.486554] =A0[<ffffffff8100aa87>] ?
> cpu_idle+0xb7/0x110
> May 10 15:26:40 os02 kernel: [ 3652.486558] =A0[<ffffffff81538ffe>] ?
> start_secondary+0x21f/0x221
> May 10 15:26:40 os02 kernel: [ 3652.486561] Mem-Info:
> May 10 15:26:40 os02 kernel: [ 3652.486562] Node 0 DMA per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.486564] CPU =A0 =A00: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486567] CPU =A0 =A01: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486569] CPU =A0 =A02: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486571] CPU =A0 =A03: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486573] CPU =A0 =A04: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486575] CPU =A0 =A05: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486578] CPU =A0 =A06: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486580] CPU =A0 =A07: hi: =A0 =A00, b=
tch:
> =A01 usd: =A0 0
> May 10 15:26:40 os02 kernel: [ 3652.486581] Node 0 DMA32 per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.486584] CPU =A0 =A00: hi: =A0186, btc=
h:
> 31 usd: 144
> May 10 15:26:40 os02 kernel: [ 3652.486586] CPU =A0 =A01: hi: =A0186, btc=
h:
> 31 usd: 198
> May 10 15:26:40 os02 kernel: [ 3652.486588] CPU =A0 =A02: hi: =A0186, btc=
h:
> 31 usd: 180
> May 10 15:26:40 os02 kernel: [ 3652.486590] CPU =A0 =A03: hi: =A0186, btc=
h:
> 31 usd: 172
> May 10 15:26:40 os02 kernel: [ 3652.486593] CPU =A0 =A04: hi: =A0186, btc=
h:
> 31 usd: 159
> May 10 15:26:40 os02 kernel: [ 3652.486595] CPU =A0 =A05: hi: =A0186, btc=
h:
> 31 usd: =A069
> May 10 15:26:40 os02 kernel: [ 3652.486597] CPU =A0 =A06: hi: =A0186, btc=
h:
> 31 usd: 180
> May 10 15:26:40 os02 kernel: [ 3652.486599] CPU =A0 =A07: hi: =A0186, btc=
h:
> 31 usd: 184
> May 10 15:26:40 os02 kernel: [ 3652.486601] Node 0 Normal per-cpu:
> May 10 15:26:40 os02 kernel: [ 3652.486603] CPU =A0 =A00: hi: =A0186, btc=
h:
> 31 usd: 162
> May 10 15:26:40 os02 kernel: [ 3652.486605] CPU =A0 =A01: hi: =A0186, btc=
h:
> 31 usd: =A047
> May 10 15:26:40 os02 kernel: [ 3652.486608] CPU =A0 =A02: hi: =A0186, btc=
h:
> 31 usd: 168
> May 10 15:26:40 os02 kernel: [ 3652.486610] CPU =A0 =A03: hi: =A0186, btc=
h:
> 31 usd: 141
> May 10 15:26:40 os02 kernel: [ 3652.486612] CPU =A0 =A04: hi: =A0186, btc=
h:
> 31 usd: 177
> May 10 15:26:40 os02 kernel: [ 3652.486614] CPU =A0 =A05: hi: =A0186, btc=
h:
> 31 usd: =A077
> May 10 15:26:40 os02 kernel: [ 3652.486616] CPU =A0 =A06: hi: =A0186, btc=
h:
> 31 usd: 168
> May 10 15:26:40 os02 kernel: [ 3652.486618] CPU =A0 =A07: hi: =A0186, btc=
h:
> 31 usd: 174
> May 10 15:26:40 os02 kernel: [ 3652.486624] active_anon:255806
> inactive_anon:19454 isolated_anon:0
> May 10 15:26:40 os02 kernel: [ 3652.486625] =A0active_file:420093
> inactive_file:5180745 isolated_file:0
> May 10 15:26:40 os02 kernel: [ 3652.486627] =A0unevictable:50582
> dirty:314470 writeback:8484 unstable:0
> May 10 15:26:40 os02 kernel: [ 3652.486628] =A0free:29795
> slab_reclaimable:35739 slab_unreclaimable:13526
> May 10 15:26:40 os02 kernel: [ 3652.486629] =A0mapped:3440 shmem:51
> pagetables:1342 bounce:0
> May 10 15:26:40 os02 kernel: [ 3652.486631] Node 0 DMA free:15852kB
> min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB
> active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:15660kB mlocked:0kB dirty:0kB writeback:0kB
> mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
> kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> May 10 15:26:40 os02 kernel: [ 3652.486642] lowmem_reserve[]: 0 2991 2420=
1 24201
> May 10 15:26:40 os02 kernel: [ 3652.486645] Node 0 DMA32 free:85748kB
> min:2460kB low:3072kB high:3688kB active_anon:20480kB
> inactive_anon:5268kB active_file:151588kB inactive_file:2645188kB
> unevictable:72kB isolated(anon):0kB isolated(file):0kB
> present:3063392kB mlocked:0kB dirty:210820kB writeback:0kB
> mapped:648kB shmem:0kB slab_reclaimable:28400kB
> slab_unreclaimable:2152kB kernel_stack:520kB pagetables:100kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> May 10 15:26:40 os02 kernel: [ 3652.486657] lowmem_reserve[]: 0 0 21210 2=
1210
> May 10 15:26:40 os02 kernel: [ 3652.486660] Node 0 Normal free:17580kB
> min:17440kB low:21800kB high:26160kB active_anon:1002744kB
> inactive_anon:72548kB active_file:1528784kB inactive_file:18077792kB
> unevictable:202256kB isolated(anon):0kB isolated(file):0kB
> present:21719040kB mlocked:0kB dirty:1047060kB writeback:33936kB
> mapped:13112kB shmem:204kB slab_reclaimable:114556kB
> slab_unreclaimable:51952kB kernel_stack:3768kB pagetables:5268kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:64
> all_unreclaimable? no
> May 10 15:26:40 os02 kernel: [ 3652.486673] lowmem_reserve[]: 0 0 0 0
> May 10 15:26:40 os02 kernel: [ 3652.486675] Node 0 DMA: 1*4kB 1*8kB
> 0*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB
> 3*4096kB =3D 15852kB
> May 10 15:26:40 os02 kernel: [ 3652.486684] Node 0 DMA32: 59*4kB
> 125*8kB 66*16kB 80*32kB 188*64kB 51*128kB 15*256kB 40*512kB 31*1024kB
> 1*2048kB 1*4096kB =3D 85620kB
> May 10 15:26:40 os02 kernel: [ 3652.486692] Node 0 Normal: 3705*4kB
> 12*8kB 16*16kB 4*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB
> 0*4096kB =3D 18180kB
> May 10 15:26:40 os02 kernel: [ 3652.486700] 5651289 total pagecache pages
> May 10 15:26:40 os02 kernel: [ 3652.486702] 0 pages in swap cache
> May 10 15:26:40 os02 kernel: [ 3652.486704] Swap cache stats: add 0,
> delete 0, find 0/0
> May 10 15:26:40 os02 kernel: [ 3652.486705] Free swap =A0=3D 1048572kB
> May 10 15:26:40 os02 kernel: [ 3652.486707] Total swap =3D 1048572kB
> May 10 15:26:40 os02 kernel: [ 3652.562795] 6291440 pages RAM
> May 10 15:26:40 os02 kernel: [ 3652.562798] 108688 pages reserved
> May 10 15:26:40 os02 kernel: [ 3652.562799] 5429575 pages shared
> May 10 15:26:40 os02 kernel: [ 3652.562801] 783596 pages non-shared
> May 10 15:26:40 os02 kernel: [ 3652.651570] 6291440 pages RAM
> May 10 15:26:40 os02 kernel: [ 3652.651572] 108688 pages reserved
> May 10 15:26:40 os02 kernel: [ 3652.651573] 5430055 pages shared
> May 10 15:26:40 os02 kernel: [ 3652.651575] 782974 pages non-shared
> May 10 15:26:40 os02 kernel: [ 3652.721553] 6291440 pages RAM
> May 10 15:26:40 os02 kernel: [ 3652.721555] 108688 pages reserved
> May 10 15:26:40 os02 kernel: [ 3652.721556] 5430961 pages shared
> May 10 15:26:40 os02 kernel: [ 3652.721557] 781496 pages non-shared
> May 10 15:26:40 os02 kernel: [ 3654.349865] Pid: 1846, comm: cosd
> Tainted: P =A0 =A0 =A0 =A0W =A0 2.6.38.6-1.fits.1.el6.x86_64 #1
> May 10 15:26:40 os02 kernel: [ 3654.358792] Call Trace:
> May 10 15:26:40 os02 kernel: [ 3654.361519] =A0<IRQ>
> [<ffffffff81108ce7>] ? __alloc_pages_nodemask+0x6f7/0x8a0
> May 10 15:26:40 os02 kernel: [ 3654.369495] =A0[<ffffffff814b0ad0>] ?
> ip_local_deliver+0x80/0x90
> May 10 15:26:40 os02 kernel: [ 3654.376005] =A0[<ffffffff81146cd2>] ?
> kmalloc_large_node+0x62/0xb0
> May 10 15:26:40 os02 kernel: [ 3654.382703] =A0[<ffffffff8114becb>] ?
> __kmalloc_node_track_caller+0x15b/0x1d0
> May 10 15:26:40 os02 kernel: [ 3654.390464] =A0[<ffffffff81466f74>] ?
> __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3654.397163] =A0[<ffffffff81466713>] ?
> __alloc_skb+0x83/0x170
> May 10 15:26:40 os02 kernel: [ 3654.403277] =A0[<ffffffff81466f74>] ?
> __netdev_alloc_skb+0x24/0x50
> May 10 15:26:40 os02 kernel: [ 3654.409970] =A0[<ffffffffa005d9aa>] ?
> ixgbe_alloc_rx_buffers+0x9a/0x450 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3654.417926] =A0[<ffffffff812b79e0>] ?
> swiotlb_map_page+0x0/0x110
> May 10 15:26:40 os02 kernel: [ 3654.424432] =A0[<ffffffffa0060930>] ?
> ixgbe_poll+0x1140/0x1670 [ixgbe]
> May 10 15:26:40 os02 kernel: [ 3654.431518] =A0[<ffffffff810f33eb>] ?
> perf_pmu_enable+0x2b/0x40
> May 10 15:26:40 os02 kernel: [ 3654.437924] =A0[<ffffffff81474eb2>] ?
> net_rx_action+0x102/0x2a0
> May 10 15:26:40 os02 kernel: [ 3654.444329] =A0[<ffffffff8106b745>] ?
> __do_softirq+0xb5/0x210
> May 10 15:26:40 os02 kernel: [ 3654.450541] =A0[<ffffffff810c7ca4>] ?
> handle_IRQ_event+0x54/0x180
> May 10 15:26:40 os02 kernel: [ 3654.457138] =A0[<ffffffff8106b7bd>] ?
> __do_softirq+0x12d/0x210
> May 10 15:26:40 os02 kernel: [ 3654.463446] =A0[<ffffffff8100cf3c>] ?
> call_softirq+0x1c/0x30
> May 10 15:26:40 os02 kernel: [ 3654.469562] =A0[<ffffffff8100e975>] ?
> do_softirq+0x65/0xa0
> May 10 15:26:40 os02 kernel: [ 3654.475484] =A0[<ffffffff8106b605>] ?
> irq_exit+0x95/0xa0
> May 10 15:26:40 os02 kernel: [ 3654.481218] =A0[<ffffffff8154a276>] ?
> do_IRQ+0x66/0xe0
> May 10 15:26:40 os02 kernel: [ 3654.486754] =A0[<ffffffff81542a53>] ?
> ret_from_intr+0x0/0x15
> May 10 15:26:40 os02 kernel: [ 3654.492867] =A0<EOI>
> [<ffffffff81286919>] ? __make_request+0x149/0x4c0
> May 10 15:26:40 os02 kernel: [ 3654.500061] =A0[<ffffffff812868e4>] ?
> __make_request+0x114/0x4c0
> May 10 15:26:41 os02 kernel: [ 3654.506565] =A0[<ffffffff812841bd>] ?
> generic_make_request+0x2fd/0x5e0
> May 10 15:26:41 os02 kernel: [ 3654.513649] =A0[<ffffffff8142742b>] ?
> dm_get_live_table+0x4b/0x60
> May 10 15:26:41 os02 kernel: [ 3654.520248] =A0[<ffffffff81427bc1>] ?
> dm_merge_bvec+0xc1/0x140
> May 10 15:26:41 os02 kernel: [ 3654.526555] =A0[<ffffffff81284526>] ?
> submit_bio+0x86/0x110
> May 10 15:26:41 os02 kernel: [ 3654.532574] =A0[<ffffffff8118deac>] ?
> dio_bio_submit+0xbc/0xc0
> May 10 15:26:41 os02 kernel: [ 3654.538881] =A0[<ffffffff8118df40>] ?
> dio_send_cur_page+0x90/0xc0
> May 10 15:26:41 os02 kernel: [ 3654.545478] =A0[<ffffffff8118dfd5>] ?
> submit_page_section+0x65/0x180
> May 10 15:26:41 os02 kernel: [ 3654.552370] =A0[<ffffffff8118e918>] ?
> __blockdev_direct_IO+0x678/0xb30
> May 10 15:26:41 os02 kernel: [ 3654.559454] =A0[<ffffffff81250eaf>] ?
> security_inode_getsecurity+0x1f/0x30
> May 10 15:26:41 os02 kernel: [ 3654.566924] =A0[<ffffffff8118c627>] ?
> blkdev_direct_IO+0x57/0x60
> May 10 15:26:41 os02 kernel: [ 3654.573414] =A0[<ffffffff8118b760>] ?
> blkdev_get_blocks+0x0/0xc0
> May 10 15:26:41 os02 kernel: [ 3654.579954] =A0[<ffffffff811008f2>] ?
> generic_file_direct_write+0xc2/0x190
> May 10 15:26:41 os02 kernel: [ 3654.587424] =A0[<ffffffff811715b6>] ?
> file_update_time+0xf6/0x170
> May 10 15:26:41 os02 kernel: [ 3654.594025] =A0[<ffffffff811023eb>] ?
> __generic_file_aio_write+0x32b/0x460
> May 10 15:26:41 os02 kernel: [ 3654.601494] =A0[<ffffffff8105c9e0>] ?
> wake_up_state+0x10/0x20
>
>
>
> and so on.
>
> --
> Stefan Majer
>
>
>
> --
> Stefan Majer
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



-- =

Stefan Majer

---------------------------------------------------------------------------=
---
Achieve unprecedented app performance and reliability
What every C/C++ and Fortran developer should know.
Learn how Intel has extended the reach of its next-generation tools
to help boost performance applications - inlcuding clusters.
http://p.sf.net/sfu/intel-dev2devmay
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
