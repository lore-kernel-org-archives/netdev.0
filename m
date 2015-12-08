From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: next-20151207 - crash in IPv6 code
Date: Tue, 08 Dec 2015 00:12:43 -0500
Message-ID: <3884.1449551563@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1449551563_2410P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1449551563_2410P
Content-Type: text/plain; charset=us-ascii

Seen this in 2 boots out of two on next-20151207 when IPV6 networking
was available.  It was stable when no net was available. Also, next-20161127 is OK.
Haven't bisected it yet - this ring any bells?

[   92.231022] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   92.231035] IP: [<ffffffffb48579cb>] nf_ct_frag6_gather+0x81b/0xba0
[   92.231046] PGD 0
[   92.231050] Oops: 0000 [#1] PREEMPT SMP

[   92.231166] Call Trace:
[   92.231170]  <IRQ>
[   92.231196]  [<ffffffffb4856e96>] ipv6_defrag+0x66/0x80
[   92.231206]  [<ffffffffb47547b2>] nf_iterate+0x62/0x80
[   92.231216]  [<ffffffffb475488a>] nf_hook_slow+0xba/0x1b0
[   92.231225]  [<ffffffffb47547d5>] ? nf_hook_slow+0x5/0x1b0
[   92.231235]  [<ffffffffb481444d>] ipv6_rcv+0x83d/0x8d0
[   92.231242]  [<ffffffffb4813c4e>] ? ipv6_rcv+0x3e/0x8d0
[   92.231251]  [<ffffffffb48139a0>] ? ip6_input_finish+0x7e0/0x7e0
[   92.231260]  [<ffffffffb47162ea>] __netif_receive_skb_core+0x60a/0xd70
[   92.231269]  [<ffffffffb4716a70>] __netif_receive_skb+0x20/0x90
[   92.231278]  [<ffffffffb4718c90>] netif_receive_skb_internal+0x70/0x1f0
[   92.231285]  [<ffffffffb4718c45>] ? netif_receive_skb_internal+0x25/0x1f0
[   92.231292]  [<ffffffffb474277b>] ? eth_type_trans+0x11b/0x200
[   92.231300]  [<ffffffffb4718e69>] netif_receive_skb+0x59/0x170
[   92.231308]  [<ffffffffb4949c00>] ieee80211_deliver_skb+0x120/0x180
[   92.231315]  [<ffffffffb494de52>] ieee80211_rx_handlers+0x2762/0x29f0
[   92.231324]  [<ffffffffb46fe300>] ? skb_queue_tail+0x20/0x50
[   92.231335]  [<ffffffffb40c5e78>] ? do_raw_spin_lock+0x148/0x1e0
[   92.231342]  [<ffffffffb40bfb46>] ? trace_hardirqs_on_caller+0x16/0x1b0
[   92.231358]  [<ffffffffb494e32e>] ieee80211_prepare_and_rx_handle+0x24e/0xa80
[   92.231365]  [<ffffffffb494ed9a>] ? ieee80211_rx_napi+0x23a/0xf00
[   92.231373]  [<ffffffffb494f097>] ieee80211_rx_napi+0x537/0xf00
[   92.231380]  [<ffffffffb494ed9a>] ? ieee80211_rx_napi+0x23a/0xf00
[   92.231391]  [<ffffffffb49118a5>] ieee80211_tasklet_handler+0xc5/0xd0
[   92.231401]  [<ffffffffb4066b85>] tasklet_action+0x1d5/0x220
[   92.231409]  [<ffffffffb40672cc>] __do_softirq+0xec/0x5a0
[   92.231417]  [<ffffffffb4067954>] irq_exit+0xd4/0xe0
[   92.231426]  [<ffffffffb49b3afa>] do_IRQ+0x6a/0x120
[   92.231434]  [<ffffffffb49b2089>] common_interrupt+0x89/0x89
[   92.231440]  <EOI>
[   92.231450]  [<ffffffffb465da3c>] ? cpuidle_enter_state+0x1ac/0x410
[   92.231458]  [<ffffffffb40bfced>] ? trace_hardirqs_on+0xd/0x10
[   92.231466]  [<ffffffffb465da47>] ? cpuidle_enter_state+0x1b7/0x410
[   92.231476]  [<ffffffffb465da3c>] ? cpuidle_enter_state+0x1ac/0x410
[   92.231485]  [<ffffffffb465dcd7>] cpuidle_enter+0x17/0x20
[   92.231494]  [<ffffffffb40b4e6d>] cpu_startup_entry+0x48d/0x520
[   92.231503]  [<ffffffffb403c874>] start_secondary+0x154/0x170
[   92.231510] Code: 8b fd ff ff 48 8b 13 48 89 10 49 8b 0e 49 39 ce 0f 84 80 01 00 00 48 8b 11 48 39 d3 0f 84 71 01 00 00 49 39 d6 0f 84 6b 01 00 00 <48
> 8b 0a 48 39 cb 0f 84 59 01 00 00 48 89 ca 49 39 d6 75 ec e9
[   92.231685] RIP  [<ffffffffb48579cb>] nf_ct_frag6_gather+0x81b/0xba0
[   92.231698]  RSP <ffff88022dd03958>
[   92.231704] CR2: 0000000000000000
[   92.231714] ---[ end trace 62089aaf8d90e56a ]---
[   94.678192] Kernel panic - not syncing: Fatal exception in interrupt
[   94.678228] Kernel Offset: 0x33000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)



--==_Exmh_1449551563_2410P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVmZmywdmEQWDXROgAQLTHQ/+JRFUV0eR5KgphbsG2/YvP4Ym/v7iKCG8
5T/yOK82BsR22YooAvavpmSOgi+Nz45ta0r4bRrdT7vLRAcnZ22xxxc2gheIVBtM
9hAuJ7BhR2cyehfyBKoRbC3ghWRmCthChHRNn2lMMBK+0cdAV72JrzGQBnNVeKQZ
GjRam6y+rYgrGhaRemWSeLCJmjItUCYlhxFHvF/PP2Zr+UNGamECFYK3NdQZHQdi
vnZuSb+4SN0XAsZE0ECbcmw8dE+nE4MtcDNJyYHTLNwGewueQ+Es4wSAMm0Y6FKv
tcf2BHNNmpbt9XaWiWDyBhFc6mge0tx6qWTR218kIw2AjYnamNbUpCFkJyl5Biwp
PGfmJi9J/38dsK9G2z8GNlXfz/JikNWZemTwdbGc/phkrhVX87YlpUgFeSqJ/hDF
Qqg3Fl6rw9J1LHsyO6aPdh+IP1/g32bAC+DSFr3VKkHB2Q6WlL4gZBNYQapVdfep
6LkeVeNV92AkHss9PWmESSHs0WvWfmlanbA60WvWfjgPdy5iY0M59Mn3+2zhRfXK
EVkQCbGdEbdYHImgMhGNnLukr77piqCqawZjjc3NJZfZ58U/bEMLTDIphaCEzFRM
bP3iIkPjrgdu3sQ9i+gUDjOzHBepwNgPWH1EWd/YdkUfkBI0AJ8sg85GF/Egiz4d
URTxOiYV+es=
=XiwE
-----END PGP SIGNATURE-----

--==_Exmh_1449551563_2410P--
