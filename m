From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Sat, 23 May 2015 20:04:19 +0200
Message-ID: <1969904.xZlo35YxmK@tachyon.chronox.de>
References: <20150522082708.GA3507@gondor.apana.org.au> <E1YviMC-00010E-Uk@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1YviMC-00010E-Uk@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 22. Mai 2015, 16:31:04 schrieb Herbert Xu:

Hi Herbert,

> This patch makes use of the new AEAD interface which uses a single
> SG list instead of separate lists for the AD and plain text.

After applying your additional patch, the "normal" AEAD operation works.

But with long messages (16 filled pages), I get the following. To test, simply 
use [1], cd libkcapi/test, compile and execute ./kcapi -y



[   59.441841] BUG: unable to handle kernel NULL pointer dereference at 
000000000000000c
[   59.441853] IP: [<ffffffff812b6d78>] scatterwalk_ffwd+0x28/0xd0
[   59.441866] PGD 78ad6067 PUD 799f5067 PMD 0 
[   59.441874] Oops: 0000 [#1] SMP 
[   59.441880] Modules linked in: ansi_cprng drbg algif_rng ccm gcm algif_aead 
algif_skcipher sha512_ssse3 sha512_generic mcryptd sha1_ssse3 sha1_generic 
crypto_user des3_ede_x86_64 des_generic cmac algif_hash af_alg 
nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT 
nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 
nf_defrag_ipv4 xt_conntrack nf_conntrack cfg80211 ebtable_nat ebtable_broute 
bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security 
ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security 
iptable_raw crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel 
aesni_intel aes_x86_64 glue_helper ablk_helper microcode joydev pcspkr 
serio_raw virtio_balloon i2c_piix4 acpi_cpufreq virtio_net qxl virtio_blk 
drm_kms_helper
[   59.441958]  ttm drm virtio_pci virtio_ring virtio
[   59.441970] CPU: 1 PID: 2338 Comm: kcapi Not tainted 4.0.0+ #220
[   59.441975] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
1.7.5-20140709_153950- 04/01/2014
[   59.441995] task: ffff88007aa1e600 ti: ffff880035998000 task.ti: 
ffff880035998000
[   59.441999] RIP: 0010:[<ffffffff812b6d78>]  [<ffffffff812b6d78>] 
scatterwalk_ffwd+0x28/0xd0
[   59.442007] RSP: 0018:ffff88003599ba98  EFLAGS: 00010202
[   59.442007] RAX: 0000000000000000 RBX: 0000000000006fe0 RCX: 
ffffea0001eaa500
[   59.442007] RDX: 0000000000001000 RSI: ffff88003599bb38 RDI: 
ffff88003599bc18
[   59.442007] RBP: ffff88003599baa8 R08: ffff88003599bcf8 R09: 
0000000000000000
[   59.442007] R10: 0000000000000000 R11: 0000000000001000 R12: 
ffff88007b802d90
[   59.442007] R13: ffff88007b3f3c40 R14: ffff88007b802d50 R15: 
ffff88007b800000
[   59.442007] FS:  00007f6cf9da6700(0000) GS:ffff88007fd00000(0000) 
knlGS:0000000000000000
[   59.442007] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   59.442007] CR2: 000000000000000c CR3: 00000000799a6000 CR4: 
00000000000407e0
[   59.442007] Stack:
[   59.442007]  ffff88007b802cf0 ffffffffa02f6380 ffff88003599bad8 
ffffffff812b7b40
[   59.442007]  ffff88007b802cb0 ffff88007b800008 0000000000000000 
ffff88007aa04000
[   59.442007]  ffff88003599bae8 ffffffff812b7c0d ffff88003599bd88 
ffffffffa02e5252
[   59.442007] Call Trace:
[   59.442007]  [<ffffffffa02f6380>] ? crypto_ccm_decrypt+0x350/0x350 [ccm]
[   59.442007]  [<ffffffff812b7b40>] old_crypt+0x50/0xe0
[   59.442007]  [<ffffffff812b7c0d>] old_encrypt+0x1d/0x20
[   59.442007]  [<ffffffffa02e5252>] aead_recvmsg+0x702/0x862 [algif_aead]
[   59.442007]  [<ffffffff8114a672>] ? __alloc_pages_nodemask+0x1a2/0x9d0
[   59.442007]  [<ffffffff81687b7a>] ? _raw_spin_unlock_bh+0x1a/0x20
[   59.442007]  [<ffffffffa02e4849>] ? aead_sendmsg+0x429/0x4c0 [algif_aead]
[   59.442007]  [<ffffffff81561528>] sock_recvmsg+0x38/0x50
[   59.442007]  [<ffffffff815615c8>] sock_read_iter+0x88/0xd0
[   59.442007]  [<ffffffff811a9990>] __vfs_read+0x90/0xc0
[   59.442007]  [<ffffffff811aa12a>] vfs_read+0x8a/0x140
[   59.442007]  [<ffffffff811aab56>] SyS_read+0x46/0xb0
[   59.442007]  [<ffffffff8168812e>] system_call_fastpath+0x12/0x71
[   59.442007] Code: 0f 1f 00 66 66 66 66 90 55 85 d2 48 89 f0 48 89 e5 41 54 
53 89 d3 74 28 8b 56 0c 49 89 fc 39 d3 73 10 eb 27 0f 1f 80 00 00 00 00 <8b> 
50 0c 39 da 77 19 29 d3 48 89 c7 e8 87 a9 05 00 85 db 75 eb 
[   59.442007] RIP  [<ffffffff812b6d78>] scatterwalk_ffwd+0x28/0xd0
[   59.442007]  RSP <ffff88003599ba98>
[   59.442007] CR2: 000000000000000c
[   59.442368] ---[ end trace 09389ca31f370515 ]---
-- 
Ciao
Stephan
