From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] latest net-next-2.6 doesnt fly
Date: Fri, 02 Apr 2010 11:40:48 +0200
Message-ID: <1270201248.1989.8.camel@edumazet-laptop>
References: <1270200783.1989.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:64894 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab0DBJkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 05:40:52 -0400
Received: by bwz1 with SMTP id 1so1398010bwz.21
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 02:40:51 -0700 (PDT)
In-Reply-To: <1270200783.1989.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 11:33 +0200, Eric Dumazet a =C3=A9crit=
 :
> On my 32bit dev machine (bnx2 + tg3)
>=20
> Suspects :
>=20
> commit 5acbbd428db47b12f137a8a2aa96b3c0a96b744e
> (net: change illegal_highdma to use dma_mask)
>=20
> [ 1946.979911] BUG: unable to handle kernel NULL pointer dereference =
at
> 000000b4
> [ 1946.980046] IP: [<c12dd30a>] dev_queue_xmit+0x47a/0x6a0
> [ 1946.980145] *pde =3D 00000000=20
> [ 1946.980228] Oops: 0000 [#61] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1946.980409] last sysfs
> file: /sys/devices/system/cpu/cpu3/cpufreq/stats/time_in_state
> [ 1946.982172] Modules linked in: xt_hashlimit ipmi_si ipmi_msghandle=
r
> hpilo bonding
> [ 1946.982442]=20
> [ 1946.982493] Pid: 9887, comm: emonitor Tainted: G      D W
> 2.6.34-rc1-01558-gba0ad27-dirty #598 /ProLiant BL460c G1
> [ 1946.982574] EIP: 0060:[<c12dd30a>] EFLAGS: 00010202 CPU: 4
> [ 1946.982632] EIP is at dev_queue_xmit+0x47a/0x6a0
> [ 1946.982687] EAX: d4cb8cb0 EBX: d4d0cf30 ECX: c1d69003 EDX: c233a24=
0
> [ 1946.982746] ESI: 00000000 EDI: eeba8800 EBP: d4f69ba8 ESP: d4f69b6=
c
> [ 1946.982804]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [ 1946.982862] Process emonitor (pid: 9887, ti=3Dd4f69000 task=3Dd5ac=
65e0
> task.ti=3Dd4f69000)
> [ 1946.982937] Stack:
> [ 1946.982987]  d5ac65e0 c1046b27 eebeff24 d4f69b88 c1073810 c12e43d5
> eebeff00 d4f69b90
> [ 1946.983274] <0> c1d69003 00000000 00000000 00000001 d4d0cf30 eebef=
f00
> eebeff24 d4f69bec
> [ 1946.983639] <0> c12e43eb eebeff48 00000000 00000b84 0000000e 00000=
246
> 00000002 d4f69bf0
> [ 1946.983857] Call Trace:
> [ 1946.983857]  [<c1046b27>] ? local_bh_enable_ip+0x67/0xd0
> [ 1946.983857]  [<c1073810>] ? trace_hardirqs_on_caller+0x20/0x190
> [ 1946.983857]  [<c12e43d5>] ? neigh_resolve_output+0xd5/0x350
> [ 1946.983857]  [<c12e43eb>] ? neigh_resolve_output+0xeb/0x350
> [ 1946.983857]  [<c12f0008>] ? qdisc_create+0x98/0x340
> [ 1946.983857]  [<c12eda50>] ? eth_header+0x0/0xb0
> [ 1946.983857]  [<c130ddc4>] ? ip_finish_output2+0xc4/0x280
> [ 1946.983857]  [<c12fe618>] ? nf_hook_slow+0x108/0x140
> [ 1946.983857]  [<c130df80>] ? ip_finish_output+0x0/0x70
> [ 1946.983857]  [<c130dfcc>] ? ip_finish_output+0x4c/0x70
> [ 1946.983857]  [<c130e0a2>] ? ip_output+0xb2/0xd0
> [ 1946.983857]  [<c130df80>] ? ip_finish_output+0x0/0x70
> [ 1946.983857]  [<c130d47d>] ? ip_local_out+0x1d/0x30
> [ 1946.983857]  [<c130d92d>] ? ip_queue_xmit+0x13d/0x380
> [ 1946.983857]  [<c10b5434>] ? get_page_from_freelist+0x254/0x510
> [ 1946.983857]  [<c12d0517>] ? __skb_clone+0x27/0xe0
> [ 1946.983857]  [<c132136d>] ? tcp_transmit_skb+0x35d/0x7a0
> [ 1946.983857]  [<c1323341>] ? tcp_write_xmit+0x1e1/0x980
> [ 1946.983857]  [<c10c6de2>] ? might_fault+0x62/0xb0
> [ 1946.983857]  [<c1323b15>] ? tcp_push_one+0x35/0x40
> [ 1946.983857]  [<c1317e28>] ? tcp_sendmsg+0x898/0x910
> [ 1946.983857]  [<c12ca08b>] ? sock_aio_write+0xfb/0x110
> [ 1946.983857]  [<c10e370d>] ? do_sync_readv_writev+0x9d/0xe0
> [ 1946.983857]  [<c10e35b0>] ? rw_copy_check_uvector+0x80/0xf0
> [ 1946.983857]  [<c10e4431>] ? do_readv_writev+0xa1/0x1b0
> [ 1946.983857]  [<c12c9f90>] ? sock_aio_write+0x0/0x110
> [ 1946.983857]  [<c10e4950>] ? rcu_read_unlock+0x0/0x50
> [ 1946.983857]  [<c10e4976>] ? rcu_read_unlock+0x26/0x50
> [ 1946.983857]  [<c10e4a6b>] ? fget_light+0xcb/0xe0
> [ 1946.983857]  [<c10e4585>] ? vfs_writev+0x45/0x60
> [ 1946.983857]  [<c10e4676>] ? sys_writev+0x46/0x70
> [ 1946.983857]  [<c1002e50>] ? sysenter_do_call+0x12/0x36
> [ 1946.983857] Code: 84 1b fd ff ff 0f b7 c9 8b b7 34 03 00 00 85 c9 =
89
> 4d f0 0f 8e 07 fd ff ff 8b 50 2c 8b 0a c1 e9 1a 8b 0c cd c0 04 cb c1 =
89
> 4d e4 <8b> 8e b4 00 00 00 85 c9 0f 84 d5 fc ff ff 8b 31 89 75 e8 8b 4=
9=20
> [ 1946.983857] EIP: [<c12dd30a>] dev_queue_xmit+0x47a/0x6a0 SS:ESP
> 0068:d4f69b6c
> [ 1946.983857] CR2: 00000000000000b4
> [ 1946.988377] ---[ end trace a6e77232ba4a3a41 ]---
>=20

So after applying following patch :

diff --git a/net/core/dev.c b/net/core/dev.c
index e19cdae..a93092c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1801,7 +1801,7 @@ EXPORT_SYMBOL(netdev_rx_csum_fault);
  * 2. No high memory really exists on this machine.
  */
=20
-static inline int illegal_highdma(struct net_device *dev, struct sk_bu=
ff *skb)
+static noinline int illegal_highdma(struct net_device *dev, struct sk_=
buff *skb)
 {
 #ifdef CONFIG_HIGHMEM
        int i;

I can confirm the problem :

[  206.020316] BUG: unable to handle kernel NULL pointer dereference at=
 000000b4
[  206.020451] IP: [<c12d76b4>] illegal_highdma+0x44/0x170
[  206.020543] *pde =3D 00000000=20
[  206.020627] Oops: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
[  206.020808] last sysfs file: /sys/devices/system/cpu/cpu3/cpufreq/st=
ats/time_in_state
[  206.020882] Modules linked in: xt_hashlimit ipmi_si ipmi_msghandler =
hpilo bonding
[  206.021148]=20
[  206.021198] Pid: 4632, comm: emonitor Tainted: G      D W  2.6.34-rc=
1-01558-gba0ad27-dirty #599 /ProLiant BL460c G1
[  206.021276] EIP: 0060:[<c12d76b4>] EFLAGS: 00010202 CPU: 4
[  206.021332] EIP is at illegal_highdma+0x44/0x170
[  206.021386] EAX: c23a7e80 EBX: 00000000 ECX: f1f75cb0 EDX: f292af30
[  206.021443] ESI: 00000001 EDI: 00000001 EBP: ee83ab68 ESP: ee83ab58
[  206.021500]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  206.021556] Process emonitor (pid: 4632, ti=3Dee83a000 task=3Dee9726=
e0 task.ti=3Dee83a000)
[  206.021629] Stack:
[  206.021678]  00000000 f292af30 00010000 f2bdc800 ee83aba8 c12dcfb9 c=
1046b27 f2976f24
[  206.021958] <0> ee83ab88 c1073810 c12e4275 f2976f00 ee83ab90 c107398=
b ee83ab9c c1046b27
[  206.022316] <0> f2976f24 f292af30 f2976f00 f2976f24 ee83abec c12e428=
b f2976f48 00000000
[  206.022717] Call Trace:
[  206.022770]  [<c12dcfb9>] ? dev_queue_xmit+0x229/0x550
[  206.022828]  [<c1046b27>] ? local_bh_enable_ip+0x67/0xd0
[  206.022885]  [<c1073810>] ? trace_hardirqs_on_caller+0x20/0x190
[  206.022943]  [<c12e4275>] ? neigh_resolve_output+0xd5/0x350
[  206.023000]  [<c107398b>] ? trace_hardirqs_on+0xb/0x10
[  206.023055]  [<c1046b27>] ? local_bh_enable_ip+0x67/0xd0
[  206.023111]  [<c12e428b>] ? neigh_resolve_output+0xeb/0x350
[  206.023169]  [<c12f0008>] ? qdisc_create+0x1f8/0x340
[  206.023225]  [<c12ed8f0>] ? eth_header+0x0/0xb0
[  206.023282]  [<c130dc64>] ? ip_finish_output2+0xc4/0x280
[  206.023339]  [<c12fe4b8>] ? nf_hook_slow+0x108/0x140
[  206.023394]  [<c130de20>] ? ip_finish_output+0x0/0x70
[  206.023450]  [<c130de6c>] ? ip_finish_output+0x4c/0x70
[  206.023506]  [<c130df42>] ? ip_output+0xb2/0xd0
[  206.023560]  [<c130de20>] ? ip_finish_output+0x0/0x70
[  206.023616]  [<c130d31d>] ? ip_local_out+0x1d/0x30
[  206.023671]  [<c130d7cd>] ? ip_queue_xmit+0x13d/0x380
[  206.023728]  [<c10b5434>] ? get_page_from_freelist+0x254/0x510
[  206.023785]  [<c12d0517>] ? __skb_clone+0x27/0xe0
[  206.023841]  [<c132120d>] ? tcp_transmit_skb+0x35d/0x7a0
[  206.023898]  [<c13231e1>] ? tcp_write_xmit+0x1e1/0x980
[  206.023955]  [<c10c6de2>] ? might_fault+0x62/0xb0
[  206.024010]  [<c13239b5>] ? tcp_push_one+0x35/0x40
[  206.024066]  [<c1317cc8>] ? tcp_sendmsg+0x898/0x910
[  206.024123]  [<c12ca08b>] ? sock_aio_write+0xfb/0x110
[  206.024180]  [<c10e370d>] ? do_sync_readv_writev+0x9d/0xe0
[  206.024237]  [<c10e35b0>] ? rw_copy_check_uvector+0x80/0xf0
[  206.024257]  [<c10e4431>] ? do_readv_writev+0xa1/0x1b0
[  206.024257]  [<c12c9f90>] ? sock_aio_write+0x0/0x110
[  206.024257]  [<c10e4950>] ? rcu_read_unlock+0x0/0x50
[  206.024257]  [<c10e4976>] ? rcu_read_unlock+0x26/0x50
[  206.024257]  [<c10e4a6b>] ? fget_light+0xcb/0xe0
[  206.024257]  [<c10e4585>] ? vfs_writev+0x45/0x60
[  206.024257]  [<c10e4676>] ? sys_writev+0x46/0x70
[  206.024257]  [<c1002e50>] ? sysenter_do_call+0x12/0x36
[  206.024257] Code: 0d 80 34 53 c1 8b 49 3c 85 c9 0f 84 37 01 00 00 8b=
 8a a0 00 00 00 8b 98 34 03 00 00 0f b7 71 04 85 f6 0f 84 1f 01 00 00 8=
b 41 2c <8b> 9b b4 00 00 00 8b 10 c1 ea 1a 85 db 8b 14 d5 c0 04 cb c1 7=
4=20
[  206.024257] EIP: [<c12d76b4>] illegal_highdma+0x44/0x170 SS:ESP 0068=
:ee83ab58
[  206.024257] CR2: 00000000000000b4
[  206.027098] ---[ end trace 2b194fa03b7756a0 ]---

c12d7670 <illegal_highdma>:
c12d7670:	55                   	push   %ebp
c12d7671:	89 e5                	mov    %esp,%ebp
c12d7673:	57                   	push   %edi
c12d7674:	56                   	push   %esi
c12d7675:	53                   	push   %ebx
c12d7676:	83 ec 04             	sub    $0x4,%esp
c12d7679:	e8 06 bd d2 ff       	call   c1003384 <mcount>
c12d767e:	f6 40 4c 20          	testb  $0x20,0x4c(%eax)
c12d7682:	0f 84 b0 00 00 00    	je     c12d7738 <illegal_highdma+0xc8>
c12d7688:	8b 0d 80 34 53 c1    	mov    0xc1533480,%ecx
c12d768e:	8b 49 3c             	mov    0x3c(%ecx),%ecx
c12d7691:	85 c9                	test   %ecx,%ecx
c12d7693:	0f 84 37 01 00 00    	je     c12d77d0 <illegal_highdma+0x160>
c12d7699:	8b 8a a0 00 00 00    	mov    0xa0(%edx),%ecx
c12d769f:	8b 98 34 03 00 00    	mov    0x334(%eax),%ebx
c12d76a5:	0f b7 71 04          	movzwl 0x4(%ecx),%esi
c12d76a9:	85 f6                	test   %esi,%esi
c12d76ab:	0f 84 1f 01 00 00    	je     c12d77d0 <illegal_highdma+0x160>
c12d76b1:	8b 41 2c             	mov    0x2c(%ecx),%eax
c12d76b4:	8b 9b b4 00 00 00    	mov    0xb4(%ebx),%ebx    << NULL POINT=
ER >>
c12d76ba:	8b 10                	mov    (%eax),%edx
c12d76bc:	c1 ea 1a             	shr    $0x1a,%edx
c12d76bf:	85 db                	test   %ebx,%ebx
c12d76c1:	8b 14 d5 c0 04 cb c1 	mov    -0x3e34fb40(,%edx,8),%edx
c12d76c8:	74 5d                	je     c12d7727 <illegal_highdma+0xb7>
c12d76ca:	8b 3b                	mov    (%ebx),%edi
c12d76cc:	83 e2 fc             	and    $0xfffffffc,%edx
c12d76cf:	89 7d f0             	mov    %edi,-0x10(%ebp)
c12d76d2:	29 d0                	sub    %edx,%eax
c12d76d4:	8b 7b 04             	mov    0x4(%ebx),%edi
c12d76d7:	c1 f8 05             	sar    $0x5,%eax
c12d76da:	c1 e0 0c             	shl    $0xc,%eax
c12d76dd:	05 ff 0f 00 00       	add    $0xfff,%eax
c12d76e2:	85 ff                	test   %edi,%edi
c12d76e4:	75 05                	jne    c12d76eb <illegal_highdma+0x7b>
c12d76e6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c12d76e9:	77 3c                	ja     c12d7727 <illegal_highdma+0xb7>
c12d76eb:	31 d2                	xor    %edx,%edx
c12d76ed:	8d 76 00             	lea    0x0(%esi),%esi
c12d76f0:	42                   	inc    %edx
c12d76f1:	39 d6                	cmp    %edx,%esi
c12d76f3:	0f 8e d7 00 00 00    	jle    c12d77d0 <illegal_highdma+0x160>
c12d76f9:	8b 59 38             	mov    0x38(%ecx),%ebx
c12d76fc:	83 c1 0c             	add    $0xc,%ecx
c12d76ff:	8b 03                	mov    (%ebx),%eax
c12d7701:	c1 e8 1a             	shr    $0x1a,%eax
c12d7704:	8b 04 c5 c0 04 cb c1 	mov    -0x3e34fb40(,%eax,8),%eax
c12d770b:	83 e0 fc             	and    $0xfffffffc,%eax
c12d770e:	29 c3                	sub    %eax,%ebx
c12d7710:	31 c0                	xor    %eax,%eax
c12d7712:	c1 fb 05             	sar    $0x5,%ebx
c12d7715:	c1 e3 0c             	shl    $0xc,%ebx
c12d7718:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
c12d771e:	39 f8                	cmp    %edi,%eax
c12d7720:	72 ce                	jb     c12d76f0 <illegal_highdma+0x80>
c12d7722:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
c12d7725:	76 c9                	jbe    c12d76f0 <illegal_highdma+0x80>
c12d7727:	83 c4 04             	add    $0x4,%esp
c12d772a:	b8 01 00 00 00       	mov    $0x1,%eax
c12d772f:	5b                   	pop    %ebx
c12d7730:	5e                   	pop    %esi
c12d7731:	5f                   	pop    %edi
c12d7732:	c9                   	leave =20
c12d7733:	c3                   	ret   =20
c12d7734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
c12d7738:	8b b2 a0 00 00 00    	mov    0xa0(%edx),%esi
c12d773e:	0f b7 7e 04          	movzwl 0x4(%esi),%edi
c12d7742:	85 ff                	test   %edi,%edi
c12d7744:	0f 84 3e ff ff ff    	je     c12d7688 <illegal_highdma+0x18>
c12d774a:	8b 4e 2c             	mov    0x2c(%esi),%ecx
c12d774d:	8b 09                	mov    (%ecx),%ecx
c12d774f:	c1 e9 18             	shr    $0x18,%ecx
c12d7752:	83 e1 03             	and    $0x3,%ecx
c12d7755:	69 c9 80 03 00 00    	imul   $0x380,%ecx,%ecx
c12d775b:	81 c1 c0 bb 56 c1    	add    $0xc156bbc0,%ecx
c12d7761:	2b 89 4c 03 00 00    	sub    0x34c(%ecx),%ecx
c12d7767:	81 f9 00 07 00 00    	cmp    $0x700,%ecx
c12d776d:	74 b8                	je     c12d7727 <illegal_highdma+0xb7>
c12d776f:	8b 1d f4 8d ca c1    	mov    0xc1ca8df4,%ebx
c12d7775:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c12d7778:	31 db                	xor    %ebx,%ebx
c12d777a:	81 f9 80 0a 00 00    	cmp    $0xa80,%ecx
c12d7780:	74 3d                	je     c12d77bf <illegal_highdma+0x14f>
c12d7782:	43                   	inc    %ebx
c12d7783:	39 fb                	cmp    %edi,%ebx
c12d7785:	0f 8d fd fe ff ff    	jge    c12d7688 <illegal_highdma+0x18>
c12d778b:	8b 4e 38             	mov    0x38(%esi),%ecx
c12d778e:	83 c6 0c             	add    $0xc,%esi
c12d7791:	8b 09                	mov    (%ecx),%ecx
c12d7793:	c1 e9 18             	shr    $0x18,%ecx
c12d7796:	83 e1 03             	and    $0x3,%ecx
c12d7799:	69 c9 80 03 00 00    	imul   $0x380,%ecx,%ecx
c12d779f:	81 c1 c0 bb 56 c1    	add    $0xc156bbc0,%ecx
c12d77a5:	2b 89 4c 03 00 00    	sub    0x34c(%ecx),%ecx
c12d77ab:	81 f9 00 07 00 00    	cmp    $0x700,%ecx
c12d77b1:	0f 84 70 ff ff ff    	je     c12d7727 <illegal_highdma+0xb7>
c12d77b7:	81 f9 80 0a 00 00    	cmp    $0xa80,%ecx
c12d77bd:	75 c3                	jne    c12d7782 <illegal_highdma+0x112>
c12d77bf:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
c12d77c3:	75 bd                	jne    c12d7782 <illegal_highdma+0x112>
c12d77c5:	8d 76 00             	lea    0x0(%esi),%esi
c12d77c8:	e9 5a ff ff ff       	jmp    c12d7727 <illegal_highdma+0xb7>
c12d77cd:	8d 76 00             	lea    0x0(%esi),%esi
c12d77d0:	83 c4 04             	add    $0x4,%esp
c12d77d3:	31 c0                	xor    %eax,%eax
c12d77d5:	5b                   	pop    %ebx
c12d77d6:	5e                   	pop    %esi
c12d77d7:	5f                   	pop    %edi
c12d77d8:	c9                   	leave =20
c12d77d9:	c3                   	ret   =20



