From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 00:00:11 +0900
Message-ID: <20161013150011.GA437@swordfish>
References: <20161010150358.GA514@swordfish>
 <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net>
 <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net>
 <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net>
 <20161013134252.GA583@swordfish>
 <1476366354.4904.31.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
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
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476366354.4904.31.camel@sipsolutions.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/13/16 15:45), Johannes Berg wrote:
> On Thu, 2016-10-13 at 22:42 +0900, Sergey Senozhatsky wrote:
> > 
> > > > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commi
> > > > t/?h=x86/vmap_stack&id=0a39cfa6fbb5d5635c85253cc7d6b44b54822afd
> > > > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commi
> > > > t/?h=x86/vmap_stack&id=bf8cfa200b5a01383ea39fc8ce2f32909767baa8
> > > 
> > > That truly sounds like something we'd rather avoid in the TX/RX
> > > paths though, which should perform well.
> > 
> > didn't fix.
> 
> It couldn't, since the new helpers weren't used in mac80211 in those
> patches yet.

indeed. I thought they were.

> >  FAIL: 00004100002cba02 > ffffc900802cba02 || 1 -> (00004100002cba02
> > >> 39) == 130
> 
> The question, though, is why precisely that fails in the crypto code.
> Can you send the Oops report itself?

kernel: BUG: unable to handle kernel NULL pointer dereference at           (null)
kernel: IP: [<ffffffff8146d2f4>] ieee80211_aes_ccm_decrypt+0x107/0x27f
kernel: PGD 0 
kernel: 
kernel: Oops: 0000 [#1] PREEMPT SMP
kernel: Modules linked in: nls_iso8859_1 nls_cp437 vfat fat mousedev psmouse serio_raw atkbd libps2 i915 coretemp i2c_algo_bit hwmon crc32c_intel mxm_wmi drm_kms_helper cfbfillrect syscopyarea cfbimgblt sysfillrect iwlmvm sysimgblt fb_sys_fops i2c_i801 cfbcopyarea ie31200_edac drm iwlwifi i2c
kernel: CPU: 3 PID: 245 Comm: irq/28-iwlwifi Not tainted 4.8.0-next-20161013-dbg-00002-ge789862-dirty #112
kernel: task: ffff88041bf01800 task.stack: ffffc900002d0000
kernel: RIP: 0010:[<ffffffff8146d2f4>]  [<ffffffff8146d2f4>] ieee80211_aes_ccm_decrypt+0x107/0x27f
kernel: RSP: 0018:ffffc900002d3770  EFLAGS: 00010246
kernel: RAX: ffffc900002d3930 RBX: ffff8804133cf606 RCX: 0000000000082000
kernel: RDX: 0000000000000000 RSI: 0000000000000018 RDI: 0000000000000a02
kernel: RBP: ffffc900002d39b8 R08: 00000000000005e4 R09: 00000004100002d3
kernel: R10: 000000000000001c R11: ffff8803e66d2d20 R12: ffff8804191c2780
kernel: R13: ffffc900002d39f0 R14: ffff8804133cf022 R15: 1ffff9200005a6ee
kernel: FS:  0000000000000000(0000) GS:ffff88041ea00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 0000000000000000 CR3: 0000000001805000 CR4: 00000000001406e0
kernel: Stack:
kernel:  0000000000000000 0000000000000000 0000000000000000 0000000000000000
kernel:  0000000000000000 0000000000000000 0000000000000000 0000000000000000
kernel:  0000000000000000 0000000000000000 0000000000000000 0000000000000000
kernel: Call Trace:
kernel:  [<ffffffff8145c405>] ieee80211_crypto_ccmp_decrypt+0x204/0x298
kernel:  [<ffffffff81476cd8>] ieee80211_rx_handlers+0x7df/0x1c1d
kernel:  [<ffffffff814790c8>] ieee80211_prepare_and_rx_handle+0xdc2/0xe79
kernel:  [<ffffffff814792e7>] ? ieee80211_rx_napi+0x168/0x7b6
kernel:  [<ffffffff8147960a>] ieee80211_rx_napi+0x48b/0x7b6
kernel:  [<ffffffff8123729e>] ? debug_smp_processor_id+0x17/0x19
kernel:  [<ffffffffa01cfe3b>] iwl_mvm_rx_rx_mpdu+0x6e6/0x751 [iwlmvm]
kernel:  [<ffffffffa01c9c49>] iwl_mvm_rx+0x7e/0x98 [iwlmvm]
kernel:  [<ffffffffa0131bca>] iwl_pcie_rx_handle+0x523/0x698 [iwlwifi]
kernel:  [<ffffffffa0133027>] iwl_pcie_irq_handler+0x46f/0x65f [iwlwifi]
kernel:  [<ffffffff810893d0>] ? irq_finalize_oneshot+0xd4/0xd4
kernel:  [<ffffffff810893ed>] irq_thread_fn+0x1d/0x34
kernel:  [<ffffffff81089661>] irq_thread+0xe6/0x1bb
kernel:  [<ffffffff810894e6>] ? wake_threads_waitq+0x2c/0x2c
kernel:  [<ffffffff8108957b>] ? irq_thread_dtor+0x95/0x95
kernel:  [<ffffffff8105d762>] kthread+0xfc/0x104
kernel:  [<ffffffff8107d36c>] ? put_lock_stats.isra.9+0xe/0x20
kernel:  [<ffffffff8105d666>] ? kthread_create_on_node+0x3f/0x3f
kernel:  [<ffffffff814b2852>] ret_from_fork+0x22/0x30
kernel: Code: 01 ca 49 89 d1 48 89 d1 48 c1 ea 23 48 8b 14 d5 80 23 63 82 49 c1 e9 0c 48 c1 e9 1b 48 85 d2 74 0a 0f b6 c9 48 c1 e1 04 48 01 ca <48> 8b 12 49 c1 e1 06 b9 00 00 00 80 89 7d 80 89 75 84 48 8b 3d 
kernel: RIP  [<ffffffff8146d2f4>] ieee80211_aes_ccm_decrypt+0x107/0x27f
kernel:  RSP <ffffc900002d3770>
kernel: CR2: 0000000000000000
kernel: ---[ end trace 3cd1fcd496516f72 ]---

	-ss
