From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] latest net-next-2.6 doesnt fly
Date: Fri, 02 Apr 2010 11:58:24 +0200
Message-ID: <1270202304.1989.14.camel@edumazet-laptop>
References: <1270200783.1989.4.camel@edumazet-laptop>
	 <1270201248.1989.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:42861 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017Ab0DBJ62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 05:58:28 -0400
Received: by bwz1 with SMTP id 1so1406256bwz.21
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 02:58:26 -0700 (PDT)
In-Reply-To: <1270201248.1989.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 11:40 +0200, Eric Dumazet a =C3=A9crit=
 :

>=20
> [  206.020316] BUG: unable to handle kernel NULL pointer dereference =
at 000000b4
> [  206.020451] IP: [<c12d76b4>] illegal_highdma+0x44/0x170
> [  206.020543] *pde =3D 00000000=20
> [  206.020627] Oops: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
> [  206.020808] last sysfs file: /sys/devices/system/cpu/cpu3/cpufreq/=
stats/time_in_state
> [  206.020882] Modules linked in: xt_hashlimit ipmi_si ipmi_msghandle=
r hpilo bonding
> [  206.021148]=20
> [  206.021198] Pid: 4632, comm: emonitor Tainted: G      D W  2.6.34-=
rc1-01558-gba0ad27-dirty #599 /ProLiant BL460c G1
> [  206.021276] EIP: 0060:[<c12d76b4>] EFLAGS: 00010202 CPU: 4
> [  206.021332] EIP is at illegal_highdma+0x44/0x170
> [  206.021386] EAX: c23a7e80 EBX: 00000000 ECX: f1f75cb0 EDX: f292af3=
0
> [  206.021443] ESI: 00000001 EDI: 00000001 EBP: ee83ab68 ESP: ee83ab5=
8
> [  206.021500]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [  206.021556] Process emonitor (pid: 4632, ti=3Dee83a000 task=3Dee97=
26e0 task.ti=3Dee83a000)
> [  206.021629] Stack:
> [  206.021678]  00000000 f292af30 00010000 f2bdc800 ee83aba8 c12dcfb9=
 c1046b27 f2976f24
> [  206.021958] <0> ee83ab88 c1073810 c12e4275 f2976f00 ee83ab90 c1073=
98b ee83ab9c c1046b27
> [  206.022316] <0> f2976f24 f292af30 f2976f00 f2976f24 ee83abec c12e4=
28b f2976f48 00000000
> [  206.022717] Call Trace:
> [  206.022770]  [<c12dcfb9>] ? dev_queue_xmit+0x229/0x550
> [  206.022828]  [<c1046b27>] ? local_bh_enable_ip+0x67/0xd0
> [  206.022885]  [<c1073810>] ? trace_hardirqs_on_caller+0x20/0x190
> [  206.022943]  [<c12e4275>] ? neigh_resolve_output+0xd5/0x350
> [  206.023000]  [<c107398b>] ? trace_hardirqs_on+0xb/0x10
> [  206.023055]  [<c1046b27>] ? local_bh_enable_ip+0x67/0xd0
> [  206.023111]  [<c12e428b>] ? neigh_resolve_output+0xeb/0x350
> [  206.023169]  [<c12f0008>] ? qdisc_create+0x1f8/0x340
> [  206.023225]  [<c12ed8f0>] ? eth_header+0x0/0xb0
> [  206.023282]  [<c130dc64>] ? ip_finish_output2+0xc4/0x280
> [  206.023339]  [<c12fe4b8>] ? nf_hook_slow+0x108/0x140
> [  206.023394]  [<c130de20>] ? ip_finish_output+0x0/0x70
> [  206.023450]  [<c130de6c>] ? ip_finish_output+0x4c/0x70
> [  206.023506]  [<c130df42>] ? ip_output+0xb2/0xd0
> [  206.023560]  [<c130de20>] ? ip_finish_output+0x0/0x70
> [  206.023616]  [<c130d31d>] ? ip_local_out+0x1d/0x30
> [  206.023671]  [<c130d7cd>] ? ip_queue_xmit+0x13d/0x380
> [  206.023728]  [<c10b5434>] ? get_page_from_freelist+0x254/0x510
> [  206.023785]  [<c12d0517>] ? __skb_clone+0x27/0xe0
> [  206.023841]  [<c132120d>] ? tcp_transmit_skb+0x35d/0x7a0
> [  206.023898]  [<c13231e1>] ? tcp_write_xmit+0x1e1/0x980
> [  206.023955]  [<c10c6de2>] ? might_fault+0x62/0xb0
> [  206.024010]  [<c13239b5>] ? tcp_push_one+0x35/0x40
> [  206.024066]  [<c1317cc8>] ? tcp_sendmsg+0x898/0x910
> [  206.024123]  [<c12ca08b>] ? sock_aio_write+0xfb/0x110
> [  206.024180]  [<c10e370d>] ? do_sync_readv_writev+0x9d/0xe0
> [  206.024237]  [<c10e35b0>] ? rw_copy_check_uvector+0x80/0xf0
> [  206.024257]  [<c10e4431>] ? do_readv_writev+0xa1/0x1b0
> [  206.024257]  [<c12c9f90>] ? sock_aio_write+0x0/0x110
> [  206.024257]  [<c10e4950>] ? rcu_read_unlock+0x0/0x50
> [  206.024257]  [<c10e4976>] ? rcu_read_unlock+0x26/0x50
> [  206.024257]  [<c10e4a6b>] ? fget_light+0xcb/0xe0
> [  206.024257]  [<c10e4585>] ? vfs_writev+0x45/0x60
> [  206.024257]  [<c10e4676>] ? sys_writev+0x46/0x70
> [  206.024257]  [<c1002e50>] ? sysenter_do_call+0x12/0x36
> [  206.024257] Code: 0d 80 34 53 c1 8b 49 3c 85 c9 0f 84 37 01 00 00 =
8b 8a a0 00 00 00 8b 98 34 03 00 00 0f b7 71 04 85 f6 0f 84 1f 01 00 00=
 8b 41 2c <8b> 9b b4 00 00 00 8b 10 c1 ea 1a 85 db 8b 14 d5 c0 04 cb c1=
 74=20
> [  206.024257] EIP: [<c12d76b4>] illegal_highdma+0x44/0x170 SS:ESP 00=
68:ee83ab58
> [  206.024257] CR2: 00000000000000b4
> [  206.027098] ---[ end trace 2b194fa03b7756a0 ]---

Here is the patch I did to solve this problem

[PATCH net-next-2.6] net: illegal_highdma() fix

=46ollowup to commit 5acbbd428db47b12f137a8a2aa96b3c0a96b744e
(net: change illegal_highdma to use dma_mask)

If dev->dev.parent is NULL, we should not try to dereference it.

Dont force inline illegal_highdma() as its pretty big now.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e19cdae..c6b5206 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1801,7 +1801,7 @@ EXPORT_SYMBOL(netdev_rx_csum_fault);
  * 2. No high memory really exists on this machine.
  */
=20
-static inline int illegal_highdma(struct net_device *dev, struct sk_bu=
ff *skb)
+static int illegal_highdma(struct net_device *dev, struct sk_buff *skb=
)
 {
 #ifdef CONFIG_HIGHMEM
 	int i;
@@ -1814,6 +1814,8 @@ static inline int illegal_highdma(struct net_devi=
ce *dev, struct sk_buff *skb)
 	if (PCI_DMA_BUS_IS_PHYS) {
 		struct device *pdev =3D dev->dev.parent;
=20
+		if (!pdev)
+			return 0;
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			dma_addr_t addr =3D page_to_phys(skb_shinfo(skb)->frags[i].page);
 			if (!pdev->dma_mask || addr + PAGE_SIZE - 1 > *pdev->dma_mask)


