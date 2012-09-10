From: Horia Geanta <horia.geanta@freescale.com>
Subject: Re: zero length sg in scatterwalk_start.
Date: Tue, 11 Sep 2012 00:48:07 +0300
Message-ID: <504E6017.6070503@freescale.com>
References: <bug-855961-176318@bugzilla.redhat.com> <20120910191208.GA20865@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Fedora Kernel Team <kernel-team@fedoraproject.org>,
	<sergei.litvinenko@gmail.com>, <herbert@gondor.hengli.com.au>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:30116
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756534Ab2IJVsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 17:48:08 -0400
In-Reply-To: <20120910191208.GA20865@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/10/2012 10:12 PM, Dave Jones wrote:
> Sergei (Cc'd) just filed this against our 3.6rc4 kernel
>
> It's falling over on the
>
> BUG_ON(!sg->length);
>
> in scatterwalk_start

AFAICT, this is the same issue as the one reported here:
http://lkml.org/lkml/2012/9/9/23

Could you please try the fix proposed:
http://lkml.org/lkml/2012/9/9/97
and hopefully provide your Tested-by ?

Horia

>
> 	Dave
>
> On Mon, Sep 10, 2012 at 06:41:07PM +0000, bugzilla@redhat.com wrote:
>   > https://bugzilla.redhat.com/show_bug.cgi?id=855961
>   >
>   > Description of problem:
>   >
>   > Message with diagnostic and openswan stop to work
>   >
>   > Version-Release number of selected component (if applicable):
>   > kernel-3.6.0-0.rc4.git2.1.fc18.i686
>   > openswan-2.6.38-3.fc18.i686
>   >
>   >
>   > Steps to Reproduce:
>   > 1. Install f18 to KVM
>   > 2. install openswan
>   > 3. prepare configuration on Host and kvm guest:
>   >
>   > conn fedora18
>   > #----------------------------------
>   >         left=10.x.x.100
>   >         leftrsasigkey=0sAQPHXz0 ...
>   > #----------------------------------
>   >         right=10.x.x.18
>   >         rightrsasigkey=0sAQOi...
>   > #----------------------------------
>   >         type=transport
>   >         keyingtries=%forever
>   >         auth=esp
>   >         ike=aes256-sha1-modp1024
>   >         esp=aes256-sha1
>   >         authby=rsasig
>   >         keyexchange=ike
>   >         disablearrivalcheck=yes
>   >         pfs=no
>   >         compress=no
>   >         #-----------------------------
>   >         auto=add
>   >
>   > 4. run from host: ipsec auto --up fedora18
>   >
>   > Actual results:
>   >
>   > Message ... and ipsec service is not accessible any more. Guest do not crash
>   > and stil work (accessible by ssh).
>   >
>   > Expected results:
>   > ipsec start and work
>   >
>   >
>   > [  105.063277] ------------[ cut here ]------------
>   > [  105.063281] kernel BUG at crypto/scatterwalk.c:37!
>   > [  105.063283] invalid opcode: 0000 [#1] SMP
>   > [  105.063286] Modules linked in: authenc rmd160 crypto_null camellia_generic lzo cast6 cast5 deflate zlib_deflate cts gcm ccm serpent_sse2_i586 xts serpent_generic lrw gf128mul glue_helper blowfish_generic blowfish_common twofish_generic twofish_i586 twofish_common xcbc sha512_generic des_generic geode_aes ah6 ah4 esp6 esp4 xfrm4_mode_beet xfrm4_tunnel tunnel4 xfrm4_mode_tunnel xfrm4_mode_transport xfrm6_mode_transport xfrm6_mode_ro xfrm6_mode_beet xfrm6_mode_tunnel ipcomp ipcomp6 xfrm6_tunnel tunnel6 xfrm_ipcomp af_key lockd sunrpc bnep bluetooth rfkill ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ppdev microcode virtio_net i2c_piix4 parport_pc i2c_core parport uinput virtio_blk
>   > [  105.063327] Pid: 995, comm: cryptomgr_test Not tainted 3.6.0-0.rc4.git2.1.fc18.i686 #1 Bochs Bochs
>   > [  105.063329] EIP: 0060:[<c06829e9>] EFLAGS: 00010246 CPU: 0
>   > [  105.063363] EIP is at scatterwalk_start+0x19/0x20
>   > [  105.063365] EAX: f334bbe0 EBX: f286a5d8 ECX: 00000000 EDX: f286a5d8
>   > [  105.063367] ESI: 00000020 EDI: 00000000 EBP: f334bbd0 ESP: f334bbd0
>   > [  105.063368]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
>   > [  105.063372] CR0: 8005003b CR2: 45cb04bc CR3: 00ede000 CR4: 000006d0
>   > [  105.063381] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>   > [  105.063386] DR6: ffff0ff0 DR7: 00000400
>   > [  105.063388] Process cryptomgr_test (pid: 995, ti=f334a000 task=f26e5640 task.ti=f334a000)
>   > [  105.063389] Stack:
>   > [  105.063390]  f334bbf4 c0682bfa f334bbe0 f286a640 f286a5d8 f80851a3 f286a5a0 f286a5d8
>   > [  105.063395]  f3378a50 f334bc38 f80859db 00000014 00000001 f2bd5000 00000000 87654321
>   > [  105.063400]  00000668 f54cdc80 00000200 00000000 00000000 f286a5d8 00000020 f286a678
>   > [  105.063406] Call Trace:
>   > [  105.063409]  [<c0682bfa>] scatterwalk_map_and_copy+0x2a/0xa0
>   > [  105.063413]  [<f80851a3>] ? crypto_authenc_ahash+0x63/0x80 [authenc]
>   > [  105.063416]  [<f80859db>] crypto_authenc_genicv+0xdb/0x330 [authenc]
>   > [  105.063419]  [<f8085dbc>] crypto_authenc_encrypt+0x8c/0xa0 [authenc]
>   > [  105.063422]  [<c068a48a>] test_aead+0x5aa/0xd40
>   > [  105.063432]  [<c047e685>] ? local_clock+0x65/0x70
>   > [  105.063444]  [<c055d239>] ? deactivate_slab+0x419/0x540
>   > [  105.063449]  [<c04a7f84>] ? trace_hardirqs_on_caller+0xf4/0x180
>   > [  105.063451]  [<c04a801b>] ? trace_hardirqs_on+0xb/0x10
>   > [  105.063455]  [<c068113d>] ? __crypto_alloc_tfm+0x3d/0x150
>   > [  105.063457]  [<c068113d>] ? __crypto_alloc_tfm+0x3d/0x150
>   > [  105.063460]  [<c055e2eb>] ? __kmalloc+0x11b/0x290
>   > [  105.063463]  [<c068121f>] ? __crypto_alloc_tfm+0x11f/0x150
>   > [  105.063466]  [<c0681bcd>] ? crypto_spawn_tfm+0x3d/0x70
>   > [  105.063468]  [<c068f6d2>] ? crypto_cbc_init_tfm+0x22/0x40
>   > [  105.063471]  [<c06811de>] ? __crypto_alloc_tfm+0xde/0x150
>   > [  105.063473]  [<c0681bcd>] ? crypto_spawn_tfm+0x3d/0x70
>   > [  105.063476]  [<c0685022>] ? skcipher_geniv_init+0x22/0x40
>   > [  105.063478]  [<c0685edb>] ? async_chainiv_init+0x7b/0x90
>   > [  105.063481]  [<c06811de>] ? __crypto_alloc_tfm+0xde/0x150
>   > [  105.063484]  [<c068ac68>] alg_test_aead+0x48/0xa0
>   > [  105.063487]  [<c068992e>] ? alg_find_test+0x2e/0x60
>   > [  105.063489]  [<c0689a06>] alg_test+0xa6/0x270
>   > [  105.063511]  [<c09fb836>] ? _raw_spin_unlock_irqrestore+0x36/0x70
>   > [  105.063514]  [<c04a7f84>] ? trace_hardirqs_on_caller+0xf4/0x180
>   > [  105.063517]  [<c04a801b>] ? trace_hardirqs_on+0xb/0x10
>   > [  105.063519]  [<c06886c0>] ? cryptomgr_probe+0xb0/0xb0
>   > [  105.063522]  [<c0688701>] cryptomgr_test+0x41/0x50
>   > [  105.063525]  [<c046640d>] kthread+0x7d/0x90
>   > [  105.063528]  [<c0466390>] ? __init_kthread_worker+0x60/0x60
>   > [  105.063532]  [<c0a03502>] kernel_thread_helper+0x6/0x10
>   > [  105.063533] Code: c3 90 31 f6 83 c4 08 89 f0 5b 5e 5f 5d c3 66 90 66 90 55 89 e5 3e 8d 74 26 00 89 10 8b 4a 0c 85 c9 74 08 8b 52 08 5d 89 50 04 c3 <0f> 0b 90 8d 74 26 00 55 89 e5 53 3e 8d 74 26 00 89 c3 8b 00 81
>   > [  105.063565] EIP: [<c06829e9>] scatterwalk_start+0x19/0x20 SS:ESP 0068:f334bbd0
>   > [  105.063570] ---[ end trace 5057a14544445946 ]---
>   > [  105.063573] BUG: sleeping function called from invalid context at kernel/rwsem.c:20
>   > [  105.063574] in_atomic(): 1, irqs_disabled(): 0, pid: 995, name: cryptomgr_test
>   > [  105.063575] INFO: lockdep is turned off.
>   > [  105.063577] Pid: 995, comm: cryptomgr_test Tainted: G      D      3.6.0-0.rc4.git2.1.fc18.i686 #1
>   > [  105.063578] Call Trace:
>   > [  105.063581]  [<c0475227>] __might_sleep+0x167/0x210
>   > [  105.063584]  [<c09f9230>] down_read+0x20/0x8b
>   > [  105.063587]  [<c046e6ef>] ? __validate_process_creds+0x6f/0xd0
>   > [  105.063590]  [<c0457f6e>] exit_signals+0x1e/0x110
>   > [  105.063595]  [<c0446cef>] do_exit+0x9f/0xa10
>   > [  105.063597]  [<c0443b11>] ? kmsg_dump+0x21/0x210
>   > [  105.063600]  [<c0443c80>] ? kmsg_dump+0x190/0x210
>   > [  105.063602]  [<c0443c94>] ? kmsg_dump+0x1a4/0x210
>   > [  105.063605]  [<c0443b11>] ? kmsg_dump+0x21/0x210
>   > [  105.063607]  [<c09fc92a>] oops_end+0x8a/0xd0
>   > [  105.063611]  [<c04061d4>] die+0x54/0x80
>   > [  105.063613]  [<c09fc366>] do_trap+0x96/0xd0
>   > [  105.063616]  [<c0403b70>] ? do_bounds+0x90/0x90
>   > [  105.063618]  [<c0403c16>] do_invalid_op+0xa6/0xb0
>   > [  105.063620]  [<c06829e9>] ? scatterwalk_start+0x19/0x20
>   > [  105.063623]  [<c068c1ed>] ? hmac_final+0x8d/0xa0
>   > [  105.063625]  [<c0687d67>] ? crypto_shash_final+0x27/0xa0
>   > [  105.063628]  [<c0688173>] ? shash_ahash_finup+0x73/0x80
>   > [  105.063637]  [<c06c8dc8>] ? trace_hardirqs_off_thunk+0xc/0x14
>   > [  105.063640]  [<c09fc0f8>] error_code+0x6c/0x74
>   > [  105.063643]  [<c06800d8>] ? devcgroup_seq_read+0x2a8/0x2f0
>   > [  105.063645]  [<c06829e9>] ? scatterwalk_start+0x19/0x20
>   > [  105.063648]  [<c0682bfa>] scatterwalk_map_and_copy+0x2a/0xa0
>   > [  105.063651]  [<f80851a3>] ? crypto_authenc_ahash+0x63/0x80 [authenc]
>   > [  105.063653]  [<f80859db>] crypto_authenc_genicv+0xdb/0x330 [authenc]
>   > [  105.063656]  [<f8085dbc>] crypto_authenc_encrypt+0x8c/0xa0 [authenc]
>   > [  105.063659]  [<c068a48a>] test_aead+0x5aa/0xd40
>   > [  105.063661]  [<c047e685>] ? local_clock+0x65/0x70
>   > [  105.063664]  [<c055d239>] ? deactivate_slab+0x419/0x540
>   > [  105.063667]  [<c04a7f84>] ? trace_hardirqs_on_caller+0xf4/0x180
>   > [  105.063670]  [<c04a801b>] ? trace_hardirqs_on+0xb/0x10
>   > [  105.063672]  [<c068113d>] ? __crypto_alloc_tfm+0x3d/0x150
>   > [  105.063675]  [<c068113d>] ? __crypto_alloc_tfm+0x3d/0x150
>   > [  105.063678]  [<c055e2eb>] ? __kmalloc+0x11b/0x290
>   > [  105.063681]  [<c068121f>] ? __crypto_alloc_tfm+0x11f/0x150
>   > [  105.063683]  [<c0681bcd>] ? crypto_spawn_tfm+0x3d/0x70
>   > [  105.063685]  [<c068f6d2>] ? crypto_cbc_init_tfm+0x22/0x40
>   > [  105.063688]  [<c06811de>] ? __crypto_alloc_tfm+0xde/0x150
>   > [  105.063690]  [<c0681bcd>] ? crypto_spawn_tfm+0x3d/0x70
>   > [  105.063693]  [<c0685022>] ? skcipher_geniv_init+0x22/0x40
>   > [  105.063695]  [<c0685edb>] ? async_chainiv_init+0x7b/0x90
>   > [  105.063698]  [<c06811de>] ? __crypto_alloc_tfm+0xde/0x150
>   > [  105.063701]  [<c068ac68>] alg_test_aead+0x48/0xa0
>   > [  105.063703]  [<c068992e>] ? alg_find_test+0x2e/0x60
>   > [  105.063706]  [<c0689a06>] alg_test+0xa6/0x270
>   > [  105.063709]  [<c09fb836>] ? _raw_spin_unlock_irqrestore+0x36/0x70
>   > [  105.063711]  [<c04a7f84>] ? trace_hardirqs_on_caller+0xf4/0x180
>   > [  105.063713]  [<c04a801b>] ? trace_hardirqs_on+0xb/0x10
>   > [  105.063716]  [<c06886c0>] ? cryptomgr_probe+0xb0/0xb0
>   > [  105.063718]  [<c0688701>] cryptomgr_test+0x41/0x50
>   > [  105.063721]  [<c046640d>] kthread+0x7d/0x90
>   > [  105.063724]  [<c0466390>] ? __init_kthread_worker+0x60/0x60
>   > [  105.063726]  [<c0a03502>] kernel_thread_helper+0x6/0x10
>   > [  105.063728] note: cryptomgr_test[995] exited with preempt_count 1
