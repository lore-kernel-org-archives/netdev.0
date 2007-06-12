From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Tue, 12 Jun 2007 22:17:17 +0400
Message-ID: <20070612181717.GA1600@2ka.mipt.ru>
References: <20070611115926.GB18832@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40697 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202AbXFLSRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 14:17:30 -0400
Content-Disposition: inline
In-Reply-To: <20070611115926.GB18832@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 11, 2007 at 01:59:26PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> Patches are against the #splice branch of the block repo, "official" url
> of that is:
> 
> git://git.kernel.dk/data/git/linux-2.6-block.git/
> 
> and it's based on Linus main tree. Let me know if I should supply netdev
> branch patches instead, or even just provide a rolled up patch (or patch
> series) for anyone curious to test or play with it.

Hi Jens.

I've just pulled your tree (splice-net, but splice tree looks the same, git pull says
'Already up-to-date.') on top of linus git and got following bug trace. 
I will investigate it further tomorrow.

[   51.942373] ------------[ cut here ]------------
[   51.947041] kernel BUG at include/linux/mm.h:285!
[   51.951786] invalid opcode: 0000 [1] PREEMPT SMP 
[   51.956680] CPU 0 
[   51.958784] Modules linked in: button loop snd_intel8x0
snd_ac97_codec psmouse ac97_bus snd_pcm snd_timer snd soundcore
snd_page_alloc k8temp i2c_nforcen
[   51.988793] Pid: 2604, comm: splice-fromnet Not tainted
2.6.22-rc4-splice #2
[   51.995886] RIP: 0010:[<ffffffff80389b15>]  [<ffffffff80389b15>]
__skb_splice_bits+0xcd/0x201
[   52.004520] RSP: 0018:ffff810037f23c28  EFLAGS: 00010246
[   52.009872] RAX: 0000000000000000 RBX: ffff810037f23d98 RCX:
000000000000003f
[   52.017053] RDX: ffff81003fe93808 RSI: ffff81003fe93808 RDI:
000000000003c0a3
[   52.024233] RBP: ffff810037f23c78 R08: 0000000000000000 R09:
ffff81003780e4b8
[   52.031412] R10: ffffffff803b01d9 R11: ffff810037f23de8 R12:
000000000000009a
[   52.038591] R13: 0000000000000000 R14: ffff810037f23c90 R15:
00000000000005a8
[   52.045771] FS:  00002b9181d2c6d0(0000) GS:ffffffff804fb000(0000)
knlGS:0000000000000000
[   52.053920] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   52.059714] CR2: 00002b9181bb60e0 CR3: 000000003d109000 CR4:
00000000000006e0
[   52.066894] Process splice-fromnet (pid: 2604, threadinfo
ffff810037f22000, task ffff8100010f4100)
[   52.075908] Stack:  00000040000612d0 ffff810037f23c94
ffff81003780e4b8 0000000037f23c78
[   52.084214]  0000faf20000050e ffff81003780e4b8 ffff81003780e4b8
ffff81003e8f22d8
[   52.091860]  ffff81003c99c820 000000004d5f4ede ffff810037f23dd8
ffffffff8038bf20
[   52.099265] Call Trace:
[   52.101998]  [<ffffffff8038bf20>] skb_splice_bits+0x6c/0xd0
[   52.107619]  [<ffffffff803dc720>] _read_unlock_irq+0x31/0x4e
[   52.113330]  [<ffffffff803afc1c>] tcp_splice_data_recv+0x20/0x22
[   52.119386]  [<ffffffff803afaf3>] tcp_read_sock+0xa2/0x1ab
[   52.124920]  [<ffffffff803afbfc>] tcp_splice_data_recv+0x0/0x22
[   52.130888]  [<ffffffff803b0232>] tcp_splice_read+0xa1/0x21b
[   52.136593]  [<ffffffff803891cf>] sock_def_readable+0x0/0x6f
[   52.142303]  [<ffffffff80384a25>] sock_splice_read+0x15/0x17
[   52.148010]  [<ffffffff8029e773>] do_splice_to+0x76/0x88
[   52.153370]  [<ffffffff8029fc87>] sys_splice+0x1a8/0x232
[   52.158733]  [<ffffffff802097ce>] system_call+0x7e/0x83
[   52.164005] 
[   52.165544] 
[   52.165545] Code: 0f 0b eb fe 44 39 65 d4 8b 4d d4 41 0f 47 cc 90 ff
42 08 48 
[   52.175364] RIP  [<ffffffff80389b15>] __skb_splice_bits+0xcd/0x201
[   52.181636]  RSP <ffff810037f23c28>



-- 
	Evgeniy Polyakov
