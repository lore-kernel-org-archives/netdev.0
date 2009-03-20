From: Ingo Molnar <mingo@elte.hu>
Subject: 3c59x 0000:00:0b.0: DMA-API: device driver maps
	memory from kernel	text or rodata [addr=c0fffe54] [size=428]
Date: Fri, 20 Mar 2009 18:33:53 +0100
Message-ID: <20090320173353.GA3108@elte.hu>
References: <1237223130-26519-1-git-send-email-joerg.roedel@amd.com>
	<20090317120112.GP6159@amd.com> <20090318093847.GC5879@elte.hu>
	<20090318115615.GS6159@amd.com> <20090318120458.GA1601@elte.hu>
	<36697.89.102.207.186.1237380871.squirrel@mail.v3.sk>
	<20090318140949.GA20852@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Joerg Roedel <joerg.roedel@amd.com>,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20090318140949.GA20852@elte.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


FYI, triggered a new type of DMA debug warning today, this time on 
an older box, in the boomerang/vortex 3c59x driver:

[  211.098328] eth0:  setting full-duplex.
[ 1745.974321] ------------[ cut here ]------------
[ 1745.980344] WARNING: at lib/dma-debug.c:627 check_for_illegal_area+0xa6/0xe4()
[ 1745.983613] 3c59x 0000:00:0b.0: DMA-API: device driver maps memory from kernel text or rodata [addr=c0fffe54] [size=428]
[ 1745.986521] Modules linked in:
[ 1745.986521] Pid: 19063, comm: distcc Not tainted 2.6.29-rc8-tip-02734-gfd4c260-dirty #729
[ 1745.993830] Call Trace:
[ 1745.996309]  [<c102e98b>] warn_slowpath+0x5e/0x74
[ 1746.001069]  [<c124de1e>] ? memcpy+0xe/0x31
[ 1746.005322]  [<c14eb801>] ? skb_put+0x62/0x7b
[ 1746.009732]  [<c15e0cf5>] ? _spin_unlock_irqrestore+0x19/0x25
[ 1746.011540]  [<c1006274>] ? enable_8259A_irq+0x45/0x48
[ 1746.016729]  [<c105ee38>] ? handle_level_irq+0xe3/0xef
[ 1746.021921]  [<c1004efb>] ? handle_irq+0x36/0x43
[ 1746.022582]  [<c1002c35>] ? restore_nocheck_notrace+0x0/0xe
[ 1746.028198]  [<c124e0e0>] ? trace_hardirqs_on_thunk+0xc/0x10
[ 1746.033900]  [<c1002c35>] ? restore_nocheck_notrace+0x0/0xe
[ 1746.035517]  [<c125724f>] check_for_illegal_area+0xa6/0xe4
[ 1746.041046]  [<c1258382>] debug_dma_map_page+0x12a/0x13b
[ 1746.043356]  [<c1316366>] boomerang_start_xmit+0x40b/0x54c
[ 1746.048900]  [<c109c226>] ? kmem_cache_free+0xf6/0xfe
[ 1746.054013]  [<c14f34ca>] dev_hard_start_xmit+0x101/0x171
[ 1746.055471]  [<c15081bc>] __qdisc_run+0xf4/0x21f
[ 1746.060143]  [<c14f5e02>] dev_queue_xmit+0x1e2/0x2dc
[ 1746.065162]  [<c1524fc8>] ip_finish_output+0x213/0x24d
[ 1746.066360]  [<c109a489>] ? check_object+0xfa/0x156
[ 1746.071291]  [<c15252f8>] ip_output+0x4e/0x51
[ 1746.075693]  [<c1523a51>] ip_local_out+0x39/0x42
[ 1746.080366]  [<c1525727>] ip_queue_xmit+0x2ce/0x314
[ 1746.085295]  [<c109d146>] ? __kmalloc_node_track_caller+0x165/0x172
[ 1746.087612]  [<c14ec135>] ? __alloc_skb+0x38/0x115
[ 1746.092458]  [<c15391de>] ? tcp_v4_md5_do_lookup+0xa/0x36
[ 1746.097916]  [<c15350ee>] ? __tcp_select_window+0xe/0x12f
[ 1746.099368]  [<c1535b2d>] ? tcp_options_write+0x138/0x1b7
[ 1746.104820]  [<c1536257>] tcp_transmit_skb+0x452/0x492
[ 1746.110009]  [<c1537824>] tcp_write_xmit+0x21d/0x2c4
[ 1746.111029]  [<c153791d>] __tcp_push_pending_frames+0x52/0x12e
[ 1746.116912]  [<c152b3a4>] do_tcp_sendpages+0x4a9/0x4d6
[ 1746.122112]  [<c152c036>] tcp_sendpage+0x54/0x69
[ 1746.122783]  [<c14e51f7>] sock_sendpage+0x34/0x3b
[ 1746.127547]  [<c10bc5bf>] pipe_to_sendpage+0x5b/0x66
[ 1746.132576]  [<c10bd2a2>] __splice_from_pipe+0x65/0x1db
[ 1746.137853]  [<c10bc564>] ? pipe_to_sendpage+0x0/0x66
[ 1746.138956]  [<c10bd864>] splice_from_pipe+0x56/0x6d
[ 1746.143975]  [<c10bd893>] generic_splice_sendpage+0x18/0x1a
[ 1746.149599]  [<c10bc564>] ? pipe_to_sendpage+0x0/0x66
[ 1746.150703]  [<c10bca34>] do_splice_from+0xc0/0xd1
[ 1746.155547]  [<c10bcbb1>] direct_splice_actor+0x1c/0x21
[ 1746.160835]  [<c10bcfd5>] splice_direct_to_actor+0x124/0x1f1
[ 1746.162841]  [<c10bcb95>] ? direct_splice_actor+0x0/0x21
[ 1746.168203]  [<c10bd0dc>] do_splice_direct+0x3a/0x55
[ 1746.173220]  [<c10a3110>] do_sendfile+0x1b0/0x23e
[ 1746.177980]  [<c10a38af>] sys_sendfile+0x5b/0xac
[ 1746.178649]  [<c1002b74>] sysenter_do_call+0x12/0x2b
[ 1746.183668] ---[ end trace e9b0fe468818fdae ]---

	Ingo

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
