From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 00:04:43 +0900
Message-ID: <20161013150443.GB437@swordfish>
References: <20161010150358.GA514@swordfish>
 <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net>
 <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net>
 <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net>
 <20161013134252.GA583@swordfish>
 <1476366354.4904.31.camel@sipsolutions.net>
 <20161013150011.GA437@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Andy Lutomirski <luto@amacapital.net>,
        Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33285 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbcJMPYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 11:24:21 -0400
Content-Disposition: inline
In-Reply-To: <20161013150011.GA437@swordfish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/14/16 00:00), Sergey Senozhatsky wrote:
> kernel:  [<ffffffff8145c405>] ieee80211_crypto_ccmp_decrypt+0x204/0x298
> kernel:  [<ffffffff81476cd8>] ieee80211_rx_handlers+0x7df/0x1c1d
> kernel:  [<ffffffff814790c8>] ieee80211_prepare_and_rx_handle+0xdc2/0xe79
> kernel:  [<ffffffff814792e7>] ? ieee80211_rx_napi+0x168/0x7b6
> kernel:  [<ffffffff8147960a>] ieee80211_rx_napi+0x48b/0x7b6
> kernel:  [<ffffffff8123729e>] ? debug_smp_processor_id+0x17/0x19
> kernel:  [<ffffffffa01cfe3b>] iwl_mvm_rx_rx_mpdu+0x6e6/0x751 [iwlmvm]
> kernel:  [<ffffffffa01c9c49>] iwl_mvm_rx+0x7e/0x98 [iwlmvm]
> kernel:  [<ffffffffa0131bca>] iwl_pcie_rx_handle+0x523/0x698 [iwlwifi]
> kernel:  [<ffffffffa0133027>] iwl_pcie_irq_handler+0x46f/0x65f [iwlwifi]
> kernel:  [<ffffffff810893d0>] ? irq_finalize_oneshot+0xd4/0xd4
> kernel:  [<ffffffff810893ed>] irq_thread_fn+0x1d/0x34
> kernel:  [<ffffffff81089661>] irq_thread+0xe6/0x1bb
> kernel:  [<ffffffff810894e6>] ? wake_threads_waitq+0x2c/0x2c
> kernel:  [<ffffffff8108957b>] ? irq_thread_dtor+0x95/0x95
> kernel:  [<ffffffff8105d762>] kthread+0xfc/0x104
> kernel:  [<ffffffff8107d36c>] ? put_lock_stats.isra.9+0xe/0x20
> kernel:  [<ffffffff8105d666>] ? kthread_create_on_node+0x3f/0x3f
> kernel:  [<ffffffff814b2852>] ret_from_fork+0x22/0x30
> kernel: Code: 01 ca 49 89 d1 48 89 d1 48 c1 ea 23 48 8b 14 d5 80 23 63 82 49 c1 e9 0c 48 c1 e9 1b 48 85 d2 74 0a 0f b6 c9 48 c1 e1 04 48 01 ca <48> 8b 12 49 c1 e1 06 b9 00 00 00 80 89 7d 80 89 75 84 48 8b 3d 
> kernel: RIP  [<ffffffff8146d2f4>] ieee80211_aes_ccm_decrypt+0x107/0x27f

ffffffff8146d1ed <ieee80211_aes_ccm_decrypt>:
ffffffff8146d1ed:       e8 9e 67 04 00          callq  ffffffff814b3990 <__fentry__>
ffffffff8146d1f2:       55                      push   %rbp
ffffffff8146d1f3:       48 89 e5                mov    %rsp,%rbp
ffffffff8146d1f6:       41 57                   push   %r15
ffffffff8146d1f8:       41 56                   push   %r14
ffffffff8146d1fa:       49 89 ce                mov    %rcx,%r14
ffffffff8146d1fd:       41 55                   push   %r13
ffffffff8146d1ff:       41 54                   push   %r12
ffffffff8146d201:       53                      push   %rbx
ffffffff8146d202:       48 83 c4 80             add    $0xffffffffffffff80,%rsp
ffffffff8146d206:       8b 47 04                mov    0x4(%rdi),%eax
ffffffff8146d209:       48 8d 48 50             lea    0x50(%rax),%rcx
ffffffff8146d20d:       48 83 c0 5e             add    $0x5e,%rax
ffffffff8146d211:       48 c1 e8 03             shr    $0x3,%rax
ffffffff8146d215:       48 c1 e0 03             shl    $0x3,%rax
ffffffff8146d219:       48 29 c4                sub    %rax,%rsp
ffffffff8146d21c:       4c 8d 7c 24 07          lea    0x7(%rsp),%r15
ffffffff8146d221:       49 c1 ef 03             shr    $0x3,%r15
ffffffff8146d225:       4d 85 c0                test   %r8,%r8
ffffffff8146d228:       4a 8d 04 fd 00 00 00    lea    0x0(,%r15,8),%rax
ffffffff8146d22f:       00 
ffffffff8146d230:       48 89 85 70 ff ff ff    mov    %rax,-0x90(%rbp)
ffffffff8146d237:       75 0a                   jne    ffffffff8146d243 <ieee80211_aes_ccm_decrypt+0x56>
ffffffff8146d239:       b8 ea ff ff ff          mov    $0xffffffea,%eax
ffffffff8146d23e:       e9 1a 02 00 00          jmpq   ffffffff8146d45d <ieee80211_aes_ccm_decrypt+0x270>
ffffffff8146d243:       31 c0                   xor    %eax,%eax
ffffffff8146d245:       49 89 fc                mov    %rdi,%r12
ffffffff8146d248:       49 89 f5                mov    %rsi,%r13
ffffffff8146d24b:       4c 89 85 58 ff ff ff    mov    %r8,-0xa8(%rbp)
ffffffff8146d252:       4a 8d 3c fd 00 00 00    lea    0x0(,%r15,8),%rdi
ffffffff8146d259:       00 
ffffffff8146d25a:       be 03 00 00 00          mov    $0x3,%esi
ffffffff8146d25f:       4c 89 cb                mov    %r9,%rbx
ffffffff8146d262:       48 89 95 60 ff ff ff    mov    %rdx,-0xa0(%rbp)
ffffffff8146d269:       f3 aa                   rep stos %al,%es:(%rdi)
ffffffff8146d26b:       48 8d 85 78 ff ff ff    lea    -0x88(%rbp),%rax
ffffffff8146d272:       48 89 c7                mov    %rax,%rdi
ffffffff8146d275:       48 89 85 68 ff ff ff    mov    %rax,-0x98(%rbp)
ffffffff8146d27c:       e8 46 06 dc ff          callq  ffffffff8122d8c7 <sg_init_table>
ffffffff8146d281:       48 8b 95 60 ff ff ff    mov    -0xa0(%rbp),%rdx
ffffffff8146d288:       41 b9 00 00 00 80       mov    $0x80000000,%r9d
ffffffff8146d28e:       48 8b 0d 7b cd 39 00    mov    0x39cd7b(%rip),%rcx        # ffffffff8180a010 <phys_base>
ffffffff8146d295:       48 8b 85 68 ff ff ff    mov    -0x98(%rbp),%rax
ffffffff8146d29c:       4c 8b 85 58 ff ff ff    mov    -0xa8(%rbp),%r8
ffffffff8146d2a3:       0f b7 32                movzwl (%rdx),%esi
ffffffff8146d2a6:       48 83 c2 02             add    $0x2,%rdx
ffffffff8146d2aa:       89 d7                   mov    %edx,%edi
ffffffff8146d2ac:       81 e7 ff 0f 00 00       and    $0xfff,%edi
ffffffff8146d2b2:       66 c1 c6 08             rol    $0x8,%si
ffffffff8146d2b6:       4c 01 ca                add    %r9,%rdx
ffffffff8146d2b9:       0f b7 f6                movzwl %si,%esi
ffffffff8146d2bc:       72 0a                   jb     ffffffff8146d2c8 <ieee80211_aes_ccm_decrypt+0xdb>
ffffffff8146d2be:       48 b9 00 00 00 80 ff    movabs $0x77ff80000000,%rcx
ffffffff8146d2c5:       77 00 00 
ffffffff8146d2c8:       48 01 ca                add    %rcx,%rdx
ffffffff8146d2cb:       49 89 d1                mov    %rdx,%r9
ffffffff8146d2ce:       48 89 d1                mov    %rdx,%rcx
ffffffff8146d2d1:       48 c1 ea 23             shr    $0x23,%rdx
ffffffff8146d2d5:       48 8b 14 d5 80 23 63    mov    -0x7d9cdc80(,%rdx,8),%rdx
ffffffff8146d2dc:       82 
ffffffff8146d2dd:       49 c1 e9 0c             shr    $0xc,%r9
ffffffff8146d2e1:       48 c1 e9 1b             shr    $0x1b,%rcx
ffffffff8146d2e5:       48 85 d2                test   %rdx,%rdx
ffffffff8146d2e8:       74 0a                   je     ffffffff8146d2f4 <ieee80211_aes_ccm_decrypt+0x107>
ffffffff8146d2ea:       0f b6 c9                movzbl %cl,%ecx
ffffffff8146d2ed:       48 c1 e1 04             shl    $0x4,%rcx
ffffffff8146d2f1:       48 01 ca                add    %rcx,%rdx
ffffffff8146d2f4:       48 8b 12                mov    (%rdx),%rdx
			^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ffffffff8146d2f7:       49 c1 e1 06             shl    $0x6,%r9
ffffffff8146d2fb:       b9 00 00 00 80          mov    $0x80000000,%ecx
ffffffff8146d300:       89 7d 80                mov    %edi,-0x80(%rbp)
ffffffff8146d303:       89 75 84                mov    %esi,-0x7c(%rbp)
ffffffff8146d306:       48 8b 3d 03 cd 39 00    mov    0x39cd03(%rip),%rdi        # ffffffff8180a010 <phys_base>
ffffffff8146d30d:       48 83 e2 fc             and    $0xfffffffffffffffc,%rdx
ffffffff8146d311:       49 01 d1                add    %rdx,%r9
ffffffff8146d314:       48 8b 95 78 ff ff ff    mov    -0x88(%rbp),%rdx

	-ss
