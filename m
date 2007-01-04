From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] netfilter: ipt_MASQUERADE: NULL check in device_cmp [BUG] panic 2.6.20-rc3 in nf_conntrack
Date: Thu, 4 Jan 2007 14:51:55 +0100
Message-ID: <20070104135155.GA4682@ff.dom.local>
References: <20070101214000.4573f575.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?B?PT9JU08tODg1OS0yP1E/TWFsdGVfU2Nocj1GNmRlcj89?=
	<MalteSch@gmx.de>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:58591 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964831AbXADNuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 08:50:16 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070101214000.4573f575.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello,

Below I attach a patch proposal.

Regards,

Jarek P.

---
On 02-01-2007 06:40, Andrew Morton wrote:
>=20
> Begin forwarded message:
>=20
> Date: Mon, 1 Jan 2007 17:53:04 +0100
> From: Malte Schr=F6der <MalteSch@gmx.de>
> To: linux-kernel@vger.kernel.org
> Subject: [BUG] panic 2.6.20-rc3 in nf_conntrack
>=20
>=20
> Hello,
> I tried 2.6.20-rc3 with the new nf_nat stuff on my gateway machine wi=
th pppoe=20
> (ADSL) access to the internet. When I shut down my ppp0 interface the=
 kernel=20
> panics. Config and dmesg are attached.
> This kernel had the ipp2p patch from patch-o-matic-ng applied, but th=
e problem=20
> also happens without, so I didn't capture the panic without the patch=
=2E
>=20
> The machine is an athlon-xp with 512MiB ram.
> For iptables setup I use shorewall.
>=20
> Regards
> ---------------------------------------
> Malte Schr=F6der
> MalteSch@gmx.de
> ICQ# 68121508
> ---------------------------------------
>=20
=2E..
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> ifdown ppp0
>=20
> [  330.789466] netconsole: network logging started
> [  336.467373] BUG: unable to handle kernel NULL pointer dereference =
at virtual address 0000001c
> [  336.467513]  printing eip:
> [  336.467566] dff1605f
> [  336.467624] *pde =3D 00000000
> [  336.467687] Oops: 0000 [#1]
> [  336.467740] Modules linked in: netconsole rpcsec_gss_krb5 auth_rpc=
gss nfs xfrm_user xfrm4_tunnel tunnel4 ipcomp esp4 ah4 nfsd exportfs lo=
ckd nfs_acl sunrpc autofs4 button ac battery capi capifs nf_conntrack_i=
pv6 ip6table_filter ip6_tables xt_mark sch_sfq act_police cls_u32 sch_i=
ngress sch_htb ipt_ECN ipt_MASQUERADE ipt_ULOG ipt_LOG xt_state ipt_TCP=
MSS xt_tcpudp xt_pkttype iptable_raw xt_CLASSIFY xt_CONNMARK xt_MARK ip=
t_REJECT xt_length ipt_ipp2p xt_connmark ipt_owner ipt_recent ipt_ipran=
ge xt_physdev xt_policy xt_multiport xt_conntrack iptable_mangle iptabl=
e_nat nf_nat nf_conntrack_ipv4 nf_conntrack nfnetlink sit iptable_filte=
r ip_tables x_tables af_packet ipv6 deflate twofish twofish_common serp=
ent blowfish des cbc aes xcbc sha256 md5 crypto_null hmac crypto_hash a=
f_key ext3 jbd mbcache dm_snapshot dm_mirror dm_mod lp sha1 arc4 ecb bl=
kcipher cryptomgr crypto_algapi ppp_mppe ppp_defla
>  te zlib_deflate capidrv isdn tun pppoe pppox ppp_generic slhc tcp_cu=
bic snd_ac97_codec ac!
> 97_bus snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd=
 parport_pc parport soundcore b1pci b1dma b1 kernelcapi floppy pcspkr r=
eiserfs via_rhine ehci_hcd ide_disk uhci_hcd usbcore sata_via libata sc=
si_mod 3c59x mii thermal processor fan unix via82cxxx ide_core
> [  336.476053] CPU:    0
> [  336.476055] EIP:    0060:[<dff1605f>]    Not tainted VLI
> [  336.476057] EFLAGS: 00010206   (2.6.20-rc3 #0)
> [  336.476284] EIP is at device_cmp+0x1b/0x2e [ipt_MASQUERADE]
> [  336.476344] eax: de6d4000   ebx: 00000000   ecx: d944b7a0   edx: d=
d664d48
> [  336.476404] esi: 00000004   edi: 00001f58   ebp: 000003eb   esp: d=
e6d4e90
> [  336.476464] ds: 007b   es: 007b   ss: 0068
> [  336.476520] Process pppd (pid: 3846, ti=3Dde6d4000 task=3Ddeda4a90=
 task.ti=3Dde6d4000)
> [  336.476580] Stack: dd664c7c dd664c84 dfe8990d 00000004 dff16044 00=
000000 dff16b18 c164b000=20
> [  336.477024]        00000002 dff16041 c011c79f c164b000 000010d0 00=
001091 00000000 c01ea41a=20
> [  336.477527]        c164b000 c01e99d5 d98b49e0 00000000 d98b4a0c dd=
c100c0 c022200b c164b000=20
> [  336.478030] Call Trace:
> [  336.478132]  [<dfe8990d>] nf_ct_iterate_cleanup+0x62/0xda [nf_conn=
track]
> [  336.478259]  [<dff16044>] device_cmp+0x0/0x2e [ipt_MASQUERADE]
> [  336.478366]  [<dff16041>] masq_device_event+0x12/0x15 [ipt_MASQUER=
ADE]
> [  336.478468]  [<c011c79f>] notifier_call_chain+0x19/0x29
> [  336.478576]  [<c01ea41a>] dev_close+0x5c/0x60
> [  336.478678]  [<c01e99d5>] dev_change_flags+0x47/0xe4
> [  336.478845]  [<c022200b>] devinet_ioctl+0x251/0x56e
> [  336.478946]  [<c01eaa6e>] dev_ifsioc+0x113/0x3e1
> [  336.479046]  [<c018c505>] copy_to_user+0x2d/0x44
> [  336.479176]  [<c01e12ec>] sock_ioctl+0x18e/0x1ad
> [  336.479281]  [<c01e115e>] sock_ioctl+0x0/0x1ad
> [  336.479381]  [<c0151011>] do_ioctl+0x19/0x4d
> [  336.479482]  [<c010f0ee>] do_page_fault+0x277/0x511
> [  336.479589]  [<c0151244>] vfs_ioctl+0x1ff/0x216
> [  336.479758]  [<c015128e>] sys_ioctl+0x33/0x4d
> [  336.479861]  [<c0102ab2>] sysenter_past_esp+0x5f/0x85
> [  336.479980]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> [  336.480033] Code: 8b 51 40 b8 44 60 f1 df e8 6a 38 f7 ff 31 c0 c3 =
56 89 d6 8d 90 cc 00 00 00 53 31 db f6 80 8c 00 00 00 02 0f 45 da e8 4a=
 0a 20 e0 <39> 73 1c 0f 94 c0 0f b6 d8 e8 7a 08 20 e0 89 d8 5b 5e c3 55=
 31=20
> [  336.483030] EIP: [<dff1605f>] device_cmp+0x1b/0x2e [ipt_MASQUERADE=
] SS:ESP 0068:de6d4e90
> [  336.483183]  <0>Kernel panic - not syncing: Fatal exception in int=
errupt

---
Subject: [PATCH] netfilter: ipt_MASQUERADE: NULL check in device_cmp =20

nfct_nat can return NULL so check is needed in device_cmp.

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.20-rc3-/net/ipv4/netfilter/ipt_MASQUERADE.c linux-=
2.6.20-rc3/net/ipv4/netfilter/ipt_MASQUERADE.c
--- linux-2.6.20-rc3-/net/ipv4/netfilter/ipt_MASQUERADE.c	2006-12-18 09=
:00:00.000000000 +0100
+++ linux-2.6.20-rc3/net/ipv4/netfilter/ipt_MASQUERADE.c	2007-01-04 14:=
01:22.000000000 +0100
@@ -127,10 +127,12 @@ masquerade_target(struct sk_buff **pskb,
 static inline int
 device_cmp(struct ip_conntrack *i, void *ifindex)
 {
+	int ret;
 #ifdef CONFIG_NF_NAT_NEEDED
 	struct nf_conn_nat *nat =3D nfct_nat(i);
+	if (!nat)
+		return 0;
 #endif
-	int ret;
=20
 	read_lock_bh(&masq_lock);
 #ifdef CONFIG_NF_NAT_NEEDED
