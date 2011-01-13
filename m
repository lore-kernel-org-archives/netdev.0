From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in
 2.6.36.3
Date: Thu, 13 Jan 2011 05:55:36 +0100
Message-ID: <1294894536.3335.510.camel@edumazet-laptop>
References: <572050.51146.qm@web121706.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: JesseBrandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeffrey TKirsher <jeffrey.t.kirsher@intel.com>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39756 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab1AMEzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 23:55:43 -0500
Received: by wyb28 with SMTP id 28so1340602wyb.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 20:55:41 -0800 (PST)
In-Reply-To: <572050.51146.qm@web121706.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 janvier 2011 =C3=A0 15:27 -0800, Chris Rankin a =C3=A9cr=
it :
> Thanks, the problem has not reoccurred since I've rebooted the box wi=
th the new e100 module.
>=20
> However, the problem *did* reoccur when I tried just stopping network=
ing, unloading the old module, loading the new module and restarting ne=
tworking... (I think there were some residual network packets still tak=
ing up memory in the system. Maybe.)
>=20
> Jan 12 22:27:04 wellhouse kernel: ifconfig: page allocation failure. =
order:6, mode:0x8020
> Jan 12 22:27:04 wellhouse kernel: Pid: 14968, comm: ifconfig Not tain=
ted 2.6.36.3 #1
> Jan 12 22:27:04 wellhouse kernel: Call Trace:
> Jan 12 22:27:04 wellhouse kernel: [<c104b2a9>] ? __alloc_pages_nodema=
sk+0x477/0x4a6
> Jan 12 22:27:04 wellhouse kernel: [<c106177d>] ? __slab_alloc+0x1eb/0=
x396
> Jan 12 22:27:04 wellhouse kernel: [<c1004ca6>] ? dma_generic_alloc_co=
herent+0x4e/0xac
> Jan 12 22:27:04 wellhouse kernel: [<c105fb5c>] ? dma_pool_alloc+0xe5/=
0x1d9
> Jan 12 22:27:04 wellhouse kernel: [<c1004c58>] ? dma_generic_alloc_co=
herent+0x0/0xac
> Jan 12 22:27:04 wellhouse kernel: [<c66f67ee>] ? e100_rx_alloc_skb+0x=
82/0x11d [e100]
> Jan 12 22:27:07 wellhouse kernel: [<c66f687e>] ? e100_rx_alloc_skb+0x=
112/0x11d [e100]
> Jan 12 22:27:07 wellhouse kernel: [<c66f68d7>] ? e100_alloc_cbs+0x4e/=
0xfa [e100]
> Jan 12 22:27:07 wellhouse kernel: [<c66f836e>] ? e100_up+0x1b/0xf1 [e=
100]
> Jan 12 22:27:07 wellhouse kernel: [<c66f845b>] ? e100_open+0x17/0x3b =
[e100]
> Jan 12 22:27:07 wellhouse kernel: [<c1121630>] ? __dev_open+0x7c/0xa0
> Jan 12 22:27:07 wellhouse kernel: [<c11217ed>] ? __dev_change_flags+0=
x8b/0x100
> Jan 12 22:27:07 wellhouse kernel: [<c11218c3>] ? dev_change_flags+0x1=
0/0x3b
> Jan 12 22:27:07 wellhouse kernel: [<c1159880>] ? devinet_ioctl+0x25a/=
0x532
> Jan 12 22:27:07 wellhouse kernel: [<c11146d2>] ? sock_ioctl+0x1a8/0x1=
ca
> Jan 12 22:27:07 wellhouse kernel: [<c111452a>] ? sock_ioctl+0x0/0x1ca
> Jan 12 22:27:07 wellhouse kernel: [<c106e061>] ? do_vfs_ioctl+0x464/0=
x4a2
> Jan 12 22:27:07 wellhouse kernel: [<c1014ce0>] ? do_page_fault+0x2d2/=
0x2ea
> Jan 12 22:27:07 wellhouse kernel: [<c1014cc8>] ? do_page_fault+0x2ba/=
0x2ea
> Jan 12 22:27:07 wellhouse kernel: [<c10636f6>] ? sys_faccessat+0x144/=
0x151
> Jan 12 22:27:07 wellhouse kernel: [<c106e0cc>] ? sys_ioctl+0x2d/0x49
> Jan 12 22:27:07 wellhouse kernel: [<c1177dd5>] ? syscall_call+0x7/0xb
> Jan 12 22:27:07 wellhouse kernel: Mem-Info:
> Jan 12 22:27:07 wellhouse kernel: DMA per-cpu:
> Jan 12 22:27:07 wellhouse kernel: CPU    0: hi:    0, btch:   1 usd: =
  0
> Jan 12 22:27:07 wellhouse kernel: Normal per-cpu:
> Jan 12 22:27:07 wellhouse kernel: CPU    0: hi:    6, btch:   1 usd: =
  1
> Jan 12 22:27:07 wellhouse kernel: active_anon:2698 inactive_anon:3626=
 isolated_anon:0
> Jan 12 22:27:07 wellhouse kernel: active_file:2305 inactive_file:3574=
 isolated_file:0
> Jan 12 22:27:07 wellhouse kernel: unevictable:0 dirty:17 writeback:0 =
unstable:0
> Jan 12 22:27:07 wellhouse kernel: free:558 slab_reclaimable:484 slab_=
unreclaimable:1309
> Jan 12 22:27:07 wellhouse kernel: mapped:1209 shmem:650 pagetables:12=
9 bounce:0
> Jan 12 22:27:07 wellhouse kernel: DMA free:1044kB min:248kB low:308kB=
 high:372kB active_anon:3516kB inactive_anon:4004kB active_file:1784kB =
inactive_file:4216kB unevictable:0kB isolated(anon):0kB isolated(file):=
0kB present:15864kB mlocked:0kB dirty:4kB writeback:0kB mapped:988kB sh=
mem:8kB slab_reclaimable:288kB slab_unreclaimable:188kB kernel_stack:56=
kB pagetables:76kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scan=
ned:0 all_unreclaimable? no
> Jan 12 22:27:07 wellhouse kernel: lowmem_reserve[]: 0 47 47
> Jan 12 22:27:07 wellhouse kernel: Normal free:1188kB min:764kB low:95=
2kB high:1144kB active_anon:7276kB inactive_anon:10500kB active_file:74=
36kB inactive_file:10080kB unevictable:0kB isolated(anon):0kB isolated(=
file):0kB present:48768kB mlocked:0kB dirty:64kB writeback:0kB mapped:3=
848kB shmem:2592kB slab_reclaimable:1648kB slab_unreclaimable:5048kB ke=
rnel_stack:240kB pagetables:440kB unstable:0kB bounce:0kB writeback_tmp=
:0kB pages_scanned:0 all_unreclaimable? no
> Jan 12 22:27:07 wellhouse kernel: lowmem_reserve[]: 0 0 0
> Jan 12 22:27:07 wellhouse kernel: DMA: 87*4kB 9*8kB 5*16kB 3*32kB 1*6=
4kB 3*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1044kB
> Jan 12 22:27:07 wellhouse kernel: Normal: 123*4kB 11*8kB 0*16kB 1*32k=
B 1*64kB 2*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1188kB
> Jan 12 22:27:07 wellhouse kernel: 6766 total pagecache pages
> Jan 12 22:27:07 wellhouse kernel: 237 pages in swap cache
> Jan 12 22:27:07 wellhouse kernel: Swap cache stats: add 1830, delete =
1593, find 1018/1086
> Jan 12 22:27:07 wellhouse kernel: Free swap  =3D 2176336kB
> Jan 12 22:27:07 wellhouse kernel: Total swap =3D 2179596kB
> Jan 12 22:27:07 wellhouse kernel: 16383 pages RAM
> Jan 12 22:27:07 wellhouse kernel: 826 pages reserved
> Jan 12 22:27:07 wellhouse kernel: 5098 pages shared
> Jan 12 22:27:07 wellhouse kernel: 12619 pages non-shared
>=20
> I also noticed that the e100 is still using GFP_ATOMIC in one place.
> Does this mean that the problem is ultimately only truly fixable by
> freeing up some memory?


Are you referring to dma_pool_alloc(), using at line 321 :

page =3D pool_alloc_page(pool, GFP_ATOMIC);

I am not sure it can be changed (we own &pool->lock spinlock), thus
cannot sleep.

We could try :

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 4df2de7..faf254a 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -319,7 +319,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t m=
em_flags,
 		if (page->offset < pool->allocation)
 			goto ready;
 	}
-	page =3D pool_alloc_page(pool, GFP_ATOMIC);
+	page =3D pool_alloc_page(pool, GFP_ATOMIC | __GFP_NOWARN);
 	if (!page) {
 		if (mem_flags & __GFP_WAIT) {
 			DECLARE_WAITQUEUE(wait, current);


Problem is e100 allocates an order-6 page in DMA zone
(a 256 KB contigous area of ram)

This contigous area of ram is not available but just after booting...

If you change :

struct param_range cbs  =3D { .min =3D 64, .max =3D 256, .count =3D 128=
 };

to

struct param_range cbs  =3D { .min =3D 64, .max =3D 64, .count =3D 64 }=
;

the need will be reduced to 64 KB of contigous area, it should be OK
then ;)

On such small router, I doubt you need more than 64 slots in TX ring
buffer.



