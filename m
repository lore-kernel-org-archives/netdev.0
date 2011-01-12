From: Chris Rankin <rankincj@yahoo.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3
Date: Wed, 12 Jan 2011 15:27:06 -0800 (PST)
Message-ID: <572050.51146.qm@web121706.mail.ne1.yahoo.com>
References: <1294856052.3981.125.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeffrey TKirsher <jeffrey.t.kirsher@intel.com>
To: JesseBrandeburg <jesse.brandeburg@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web121706.mail.ne1.yahoo.com ([98.138.90.127]:46163 "HELO
	web121706.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755575Ab1ALX1H convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 18:27:07 -0500
In-Reply-To: <1294856052.3981.125.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, the problem has not reoccurred since I've rebooted the box with=
 the new e100 module.

However, the problem *did* reoccur when I tried just stopping networkin=
g, unloading the old module, loading the new module and restarting netw=
orking... (I think there were some residual network packets still takin=
g up memory in the system. Maybe.)

Jan 12 22:27:04 wellhouse kernel: ifconfig: page allocation failure. or=
der:6, mode:0x8020
Jan 12 22:27:04 wellhouse kernel: Pid: 14968, comm: ifconfig Not tainte=
d 2.6.36.3 #1
Jan 12 22:27:04 wellhouse kernel: Call Trace:
Jan 12 22:27:04 wellhouse kernel: [<c104b2a9>] ? __alloc_pages_nodemask=
+0x477/0x4a6
Jan 12 22:27:04 wellhouse kernel: [<c106177d>] ? __slab_alloc+0x1eb/0x3=
96
Jan 12 22:27:04 wellhouse kernel: [<c1004ca6>] ? dma_generic_alloc_cohe=
rent+0x4e/0xac
Jan 12 22:27:04 wellhouse kernel: [<c105fb5c>] ? dma_pool_alloc+0xe5/0x=
1d9
Jan 12 22:27:04 wellhouse kernel: [<c1004c58>] ? dma_generic_alloc_cohe=
rent+0x0/0xac
Jan 12 22:27:04 wellhouse kernel: [<c66f67ee>] ? e100_rx_alloc_skb+0x82=
/0x11d [e100]
Jan 12 22:27:07 wellhouse kernel: [<c66f687e>] ? e100_rx_alloc_skb+0x11=
2/0x11d [e100]
Jan 12 22:27:07 wellhouse kernel: [<c66f68d7>] ? e100_alloc_cbs+0x4e/0x=
fa [e100]
Jan 12 22:27:07 wellhouse kernel: [<c66f836e>] ? e100_up+0x1b/0xf1 [e10=
0]
Jan 12 22:27:07 wellhouse kernel: [<c66f845b>] ? e100_open+0x17/0x3b [e=
100]
Jan 12 22:27:07 wellhouse kernel: [<c1121630>] ? __dev_open+0x7c/0xa0
Jan 12 22:27:07 wellhouse kernel: [<c11217ed>] ? __dev_change_flags+0x8=
b/0x100
Jan 12 22:27:07 wellhouse kernel: [<c11218c3>] ? dev_change_flags+0x10/=
0x3b
Jan 12 22:27:07 wellhouse kernel: [<c1159880>] ? devinet_ioctl+0x25a/0x=
532
Jan 12 22:27:07 wellhouse kernel: [<c11146d2>] ? sock_ioctl+0x1a8/0x1ca
Jan 12 22:27:07 wellhouse kernel: [<c111452a>] ? sock_ioctl+0x0/0x1ca
Jan 12 22:27:07 wellhouse kernel: [<c106e061>] ? do_vfs_ioctl+0x464/0x4=
a2
Jan 12 22:27:07 wellhouse kernel: [<c1014ce0>] ? do_page_fault+0x2d2/0x=
2ea
Jan 12 22:27:07 wellhouse kernel: [<c1014cc8>] ? do_page_fault+0x2ba/0x=
2ea
Jan 12 22:27:07 wellhouse kernel: [<c10636f6>] ? sys_faccessat+0x144/0x=
151
Jan 12 22:27:07 wellhouse kernel: [<c106e0cc>] ? sys_ioctl+0x2d/0x49
Jan 12 22:27:07 wellhouse kernel: [<c1177dd5>] ? syscall_call+0x7/0xb
Jan 12 22:27:07 wellhouse kernel: Mem-Info:
Jan 12 22:27:07 wellhouse kernel: DMA per-cpu:
Jan 12 22:27:07 wellhouse kernel: CPU    0: hi:    0, btch:   1 usd:   =
0
Jan 12 22:27:07 wellhouse kernel: Normal per-cpu:
Jan 12 22:27:07 wellhouse kernel: CPU    0: hi:    6, btch:   1 usd:   =
1
Jan 12 22:27:07 wellhouse kernel: active_anon:2698 inactive_anon:3626 i=
solated_anon:0
Jan 12 22:27:07 wellhouse kernel: active_file:2305 inactive_file:3574 i=
solated_file:0
Jan 12 22:27:07 wellhouse kernel: unevictable:0 dirty:17 writeback:0 un=
stable:0
Jan 12 22:27:07 wellhouse kernel: free:558 slab_reclaimable:484 slab_un=
reclaimable:1309
Jan 12 22:27:07 wellhouse kernel: mapped:1209 shmem:650 pagetables:129 =
bounce:0
Jan 12 22:27:07 wellhouse kernel: DMA free:1044kB min:248kB low:308kB h=
igh:372kB active_anon:3516kB inactive_anon:4004kB active_file:1784kB in=
active_file:4216kB unevictable:0kB isolated(anon):0kB isolated(file):0k=
B present:15864kB mlocked:0kB dirty:4kB writeback:0kB mapped:988kB shme=
m:8kB slab_reclaimable:288kB slab_unreclaimable:188kB kernel_stack:56kB=
 pagetables:76kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanne=
d:0 all_unreclaimable? no
Jan 12 22:27:07 wellhouse kernel: lowmem_reserve[]: 0 47 47
Jan 12 22:27:07 wellhouse kernel: Normal free:1188kB min:764kB low:952k=
B high:1144kB active_anon:7276kB inactive_anon:10500kB active_file:7436=
kB inactive_file:10080kB unevictable:0kB isolated(anon):0kB isolated(fi=
le):0kB present:48768kB mlocked:0kB dirty:64kB writeback:0kB mapped:384=
8kB shmem:2592kB slab_reclaimable:1648kB slab_unreclaimable:5048kB kern=
el_stack:240kB pagetables:440kB unstable:0kB bounce:0kB writeback_tmp:0=
kB pages_scanned:0 all_unreclaimable? no
Jan 12 22:27:07 wellhouse kernel: lowmem_reserve[]: 0 0 0
Jan 12 22:27:07 wellhouse kernel: DMA: 87*4kB 9*8kB 5*16kB 3*32kB 1*64k=
B 3*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1044kB
Jan 12 22:27:07 wellhouse kernel: Normal: 123*4kB 11*8kB 0*16kB 1*32kB =
1*64kB 2*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1188kB
Jan 12 22:27:07 wellhouse kernel: 6766 total pagecache pages
Jan 12 22:27:07 wellhouse kernel: 237 pages in swap cache
Jan 12 22:27:07 wellhouse kernel: Swap cache stats: add 1830, delete 15=
93, find 1018/1086
Jan 12 22:27:07 wellhouse kernel: Free swap  =3D 2176336kB
Jan 12 22:27:07 wellhouse kernel: Total swap =3D 2179596kB
Jan 12 22:27:07 wellhouse kernel: 16383 pages RAM
Jan 12 22:27:07 wellhouse kernel: 826 pages reserved
Jan 12 22:27:07 wellhouse kernel: 5098 pages shared
Jan 12 22:27:07 wellhouse kernel: 12619 pages non-shared

I also noticed that the e100 is still using GFP_ATOMIC in one place. Do=
es this mean that the problem is ultimately only truly fixable by freei=
ng up some memory?

Cheers,
Chris

--- On Wed, 12/1/11, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) =
in 2.6.36.3
> To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
> Cc: "David Miller" <davem@davemloft.net>, "Chris Rankin" <rankincj@ya=
hoo.com>, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.source=
forge.net>, "Dave, Tushar N" <tushar.n.dave@intel.com>, "netdev@vger.ke=
rnel.org" <netdev@vger.kernel.org>, "Kirsher, Jeffrey T" <jeffrey.t.kir=
sher@intel.com>
> Date: Wednesday, 12 January, 2011, 18:14
> Le mercredi 12 janvier 2011 =E0 10:05
> -0800, Brandeburg, Jesse a =E9crit :
>=20
> > First, I don't think the following comment should hold
> up this patch.
> >=20
> > As a policy question when I asked about using
> __GFP_NOWARN before in other=20
> > Intel ethernet drivers the consensus seemed to be that
> the warning=20
> > messages were useful.=A0 All our drivers correctly
> handle runtime memory=20
> > failures, but none of them are currently using
> __GFP_NOWARN.
> >=20
> > Can I submit patches to change our other drivers to
> __GFP_NOWARN?=A0 I think=20
> > it will make for quite a few less reports of
> non-issues to the list.=A0 All=20
> > our drivers that I would be patching already have
> ethtool counters that=20
> > count failed allocations.
> >=20
>=20
> If an allocation failure is really handled, in the sense
> NIC doesnt
> freeze but only lose one incoming frame, then probably
> yes.
>=20
> I think the warning message can be useful when driver is
> known to let
> things in a non working state ;)
>=20
> As you said, this can be done later, here is a respin
> without this bit.
>=20
> Thanks !
>=20
> [PATCH v2] e100: use GFP_KERNEL allocations at device init
> stage
>=20
> In lowmem conditions, e100 driver can fail its
> initialization, because
> of GFP_ATOMIC abuse.
>=20
> Switch to GFP_KERNEL were applicable.
>=20
> Reported-by: Chris Rankin <rankincj@yahoo.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/e100.c |=A0=A0=A022
> +++++++++++++++++-----
>  1 file changed, 17 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index b0aa9e6..c9a2126 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1880,9 +1880,21 @@ static inline void
> e100_start_receiver(struct nic *nic, struct rx *rx)
>  }
> =20
>  #define RFD_BUF_LEN (sizeof(struct rfd) +
> VLAN_ETH_FRAME_LEN)
> -static int e100_rx_alloc_skb(struct nic *nic, struct rx
> *rx)
> +
> +static struct sk_buff *e100_alloc_skb(struct net_device
> *dev, gfp_t flags)
> +{
> +=A0=A0=A0 struct sk_buff *skb;
> +
> +=A0=A0=A0 skb =3D __netdev_alloc_skb(dev,
> RFD_BUF_LEN + NET_IP_ALIGN, flags);
> +=A0=A0=A0 if (NET_IP_ALIGN && skb)
> +=A0=A0=A0 =A0=A0=A0 skb_reserve(skb,
> NET_IP_ALIGN);
> +=A0=A0=A0 return skb;
> +}
> +
> +static int e100_rx_alloc_skb(struct nic *nic, struct rx
> *rx, gfp_t flags)
>  {
> -=A0=A0=A0 if (!(rx->skb =3D
> netdev_alloc_skb_ip_align(nic->netdev, RFD_BUF_LEN)))
> +=A0=A0=A0 rx->skb =3D
> e100_alloc_skb(nic->netdev, flags);
> +=A0=A0=A0 if (!rx->skb)
>  =A0=A0=A0 =A0=A0=A0 return -ENOMEM;
> =20
>  =A0=A0=A0 /* Init, and map the RFD. */
> @@ -2026,7 +2038,7 @@ static void e100_rx_clean(struct nic
> *nic, unsigned int *work_done,
> =20
>  =A0=A0=A0 /* Alloc new skbs to refill list */
>  =A0=A0=A0 for (rx =3D nic->rx_to_use;
> !rx->skb; rx =3D nic->rx_to_use =3D rx->next) {
> -=A0=A0=A0 =A0=A0=A0 if
> (unlikely(e100_rx_alloc_skb(nic, rx)))
> +=A0=A0=A0 =A0=A0=A0 if
> (unlikely(e100_rx_alloc_skb(nic, rx, GFP_ATOMIC)))
>  =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> break; /* Better luck next time (see watchdog) */
>  =A0=A0=A0 }
> =20
> @@ -2102,13 +2114,13 @@ static int
> e100_rx_alloc_list(struct nic *nic)
>  =A0=A0=A0 nic->rx_to_use =3D nic->rx_to_clean
> =3D NULL;
>  =A0=A0=A0 nic->ru_running =3D RU_UNINITIALIZED;
> =20
> -=A0=A0=A0 if (!(nic->rxs =3D kcalloc(count,
> sizeof(struct rx), GFP_ATOMIC)))
> +=A0=A0=A0 if (!(nic->rxs =3D kcalloc(count,
> sizeof(struct rx), GFP_KERNEL)))
>  =A0=A0=A0 =A0=A0=A0 return -ENOMEM;
> =20
>  =A0=A0=A0 for (rx =3D nic->rxs, i =3D 0; i <
> count; rx++, i++) {
>  =A0=A0=A0 =A0=A0=A0 rx->next =3D (i + 1
> < count) ? rx + 1 : nic->rxs;
>  =A0=A0=A0 =A0=A0=A0 rx->prev =3D (i =3D=3D
> 0) ? nic->rxs + count - 1 : rx - 1;
> -=A0=A0=A0 =A0=A0=A0 if
> (e100_rx_alloc_skb(nic, rx)) {
> +=A0=A0=A0 =A0=A0=A0 if
> (e100_rx_alloc_skb(nic, rx, GFP_KERNEL)) {
>  =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> e100_rx_clean_list(nic);
>  =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> return -ENOMEM;
>  =A0=A0=A0 =A0=A0=A0 }
>=20
>=20
>=20


     =20
