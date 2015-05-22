From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Fri, 22 May 2015 22:59:34 +0200
Message-ID: <1711949.C5mmxUsD4a@myon.chronox.de>
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

Using an up-to date tree with the full set of patches of this patch set, I get 
the following oops.

It can easily be reproduced by using [1]: go to libkcapi/test/ and compile 
with make. Then execute ./test.sh

[1] http://www.chronox.de/libkcapi.html



[   22.680910] BUG: unable to handle kernel NULL pointer dereference at           
(null)
[   22.680915] IP: [<          (null)>]           (null)
[   22.680917] PGD 3c62e067 PUD 3b28e067 PMD 0 
[   22.680919] Oops: 0010 [#1] SMP 
[   22.680921] Modules linked in: seqiv ccm gcm crypto_null algif_aead 
algif_skcipher sha512_ssse3 sha512_generic mcryptd sha1_ssse3 sha1_generic 
crypto_user des3_ede_x86_64 des_generic algif_hash af_alg 
nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT 
nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 
nf_defrag_ipv4 xt_conntrack nf_conntrack cfg80211 ebtable_nat ebtable_broute 
bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security 
ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security 
iptable_raw crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel 
aesni_intel aes_x86_64 glue_helper ablk_helper joydev microcode virtio_console 
serio_raw virtio_balloon pcspkr i2c_piix4 acpi_cpufreq qxl drm_kms_helper ttm 
drm virtio_net
[   22.680948]  virtio_blk virtio_pci virtio_ring virtio
[   22.680952] CPU: 1 PID: 1889 Comm: kcapi Not tainted 4.0.0+ #122
[   22.680954] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   22.680955] task: ffff88003c08cc80 ti: ffff88003b300000 task.ti: 
ffff88003b300000
[   22.680956] RIP: 0010:[<0000000000000000>]  [<          (null)>]           
(null)
[   22.680958] RSP: 0018:ffff88003b303ce0  EFLAGS: 00010282
[   22.680959] RAX: ffffffffa02f5080 RBX: ffffffffa0138b20 RCX: 
0000000000000001
[   22.680960] RDX: 0000000000000001 RSI: ffffffffa02f5368 RDI: 
ffff88003b303cf8
[   22.680961] RBP: ffff88003b303d88 R08: 0000000000000000 R09: 
ffffea0000ecbd00
[   22.680962] R10: ffffffff810676b4 R11: ffff88003c275240 R12: 
ffff88003b1ff200
[   22.680963] R13: 00000000fffffffe R14: ffffffffa02f5080 R15: 
0000000000000203
[   22.680965] FS:  00007fade1fe8700(0000) GS:ffff88003fd00000(0000) 
knlGS:0000000000000000
[   22.680966] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   22.680967] CR2: 0000000000000000 CR3: 000000003bdc9000 CR4: 
00000000000407e0
[   22.680971] Stack:
[   22.680973]  ffffffff812b7e6d 0002000c00000003 0000020f00000203 
ffff88003b303cec
[   22.680975]  ffff88003b303d14 0000000000000000 00010044812b49c4 
2d36303134636672
[   22.680977]  6e7365612d6d6367 0000000000000069 0000000000000000 
0000000000000000
[   22.680979] Call Trace:
[   22.680984]  [<ffffffff812b7e6d>] ? crypto_nivaead_default+0x14d/0x1a0
[   22.680986]  [<ffffffff812b7f5a>] crypto_lookup_aead+0x9a/0xf0
[   22.680989]  [<ffffffff812b4f33>] crypto_alloc_tfm+0x63/0x130
[   22.680992]  [<ffffffff81193dd1>] ? kmem_cache_alloc_trace+0x1f1/0x230
[   22.680994]  [<ffffffff812b7fc9>] crypto_alloc_aead+0x19/0x20
[   22.680996]  [<ffffffffa02d638e>] aead_bind+0xe/0x10 [algif_aead]
[   22.680999]  [<ffffffffa02848d0>] alg_bind+0x60/0x130 [af_alg]
[   22.681003]  [<ffffffff81561f68>] SYSC_bind+0xb8/0xf0
[   22.681003]  [<ffffffff811c7eb5>] ? fd_install+0x25/0x30
[   22.681003]  [<ffffffff81562850>] ? SyS_socket+0x90/0xd0
[   22.681003]  [<ffffffff8104a0f7>] ? trace_do_page_fault+0x37/0xb0
[   22.681003]  [<ffffffff81562ade>] SyS_bind+0xe/0x10
[   22.681003]  [<ffffffff81687f6e>] system_call_fastpath+0x12/0x71
[   22.681003] Code:  Bad RIP value.
[   22.681003] RIP  [<          (null)>]           (null)
[   22.681003]  RSP <ffff88003b303ce0>
[   22.681003] CR2: 0000000000000000
[   22.681053] ---[ end trace c1a8ba963ebab541 ]---

-- 
Ciao
Stephan
