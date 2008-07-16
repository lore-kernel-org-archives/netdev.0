From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: linux-next: Tree for July 11:  WARNING: at /home/rafael/src/linux-next/include/linux/blkdev.h:447
Date: Thu, 17 Jul 2008 01:02:15 +0200
Message-ID: <200807170102.16302.rjw@sisk.pl>
References: <20080711182557.9b24df1f.sfr@canb.auug.org.au> <19f34abd0807121221n75fd7bb8x24fa484239773201@mail.gmail.com> <200807122226.10699.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Vegard Nossum" <vegard.nossum@gmail.com>,
	"Stephen Rothwell" <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"Kernel Testers List" <kernel-testers@vger.kernel.org>,
	netdev@vger.kernel.org, "Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Jens Axboe" <jens.axboe@oracle.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <200807122226.10699.rjw@sisk.pl>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, 12 of July 2008, Rafael J. Wysocki wrote:
> On Saturday, 12 of July 2008, Vegard Nossum wrote:
> > On Sat, Jul 12, 2008 at 8:51 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > > and the second one is the following:
[--snip--]
> 
> It turns out that this happened before, but I've been overlooking it.  This is
> a trace from the Friday's linux-next:
> 
> ------------[ cut here ]------------
> WARNING: at /home/rafael/src/linux-next/include/linux/blkdev.h:447 blk_plug_device+0x9b/0xb0()
> Modules linked in: rtc_cmos snd_hda_intel rtc_core snd_pcm sr_mod floppy snd_timer snd_page_alloc rtc_lib ohci1394 serio_raw cdrom ieee1394 snd_hwdep snd soundcore sky2 button wmi joydev evdev sg raid456 async_xor async_memcpy async_tx xor raid0 usbhid ff_memless ehci_hcd sd_mod ohci_hcd edd raid1 ext3 jbd fan pata_marvell pata_atiixp thermal processor
> Pid: 2275, comm: kjournald Not tainted 2.6.26-rc9-next #40
> 
> Call Trace:
>  [<ffffffff8023cf9f>] warn_on_slowpath+0x5f/0x80
>  [<ffffffff80220030>] ? hpet_rtc_interrupt+0x100/0x380
>  [<ffffffff80263327>] ? __lock_acquire+0x8b7/0x1280
>  [<ffffffff80291461>] ? mempool_alloc_slab+0x11/0x20
>  [<ffffffff8035735b>] blk_plug_device+0x9b/0xb0
>  [<ffffffff8045377f>] bitmap_startwrite+0xbf/0x1b0
>  [<ffffffff802e8254>] ? bio_alloc_bioset+0x54/0xb0
>  [<ffffffffa004eafa>] make_request+0x39a/0x810 [raid1]
>  [<ffffffff802915cb>] ? mempool_alloc+0x5b/0x140
>  [<ffffffff802915cb>] ? mempool_alloc+0x5b/0x140
>  [<ffffffff803565ad>] generic_make_request+0x17d/0x2b0
>  [<ffffffff80357f5c>] submit_bio+0x6c/0xf0
>  [<ffffffff802e36d0>] submit_bh+0xf0/0x130
>  [<ffffffffa001cce0>] journal_commit_transaction+0xa40/0x1000 [jbd]
>  [<ffffffff802480d4>] ? try_to_del_timer_sync+0x44/0x90
>  [<ffffffffa0020967>] kjournald+0xe7/0x250 [jbd]
>  [<ffffffff80253ef0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffffa0020880>] ? kjournald+0x0/0x250 [jbd]
>  [<ffffffff80253a9d>] kthread+0x4d/0x80
>  [<ffffffff8020c6b9>] child_rip+0xa/0x11
>  [<ffffffff8020bcef>] ? restore_args+0x0/0x30
>  [<ffffffff80253a50>] ? kthread+0x0/0x80
>  [<ffffffff8020c6af>] ? child_rip+0x0/0x11
> 
> ---[ end trace bd85cedf792d0f08 ]---
> 

This has now made it into the Linus' tree:

------------[ cut here ]------------
WARNING: at /home/rafael/src/linux-2.6/include/linux/blkdev.h:447 blk_plug_device+0x9b/0xb0()
Modules linked in: rtc_cmos rtc_core sr_mod rtc_lib snd_hda_intel cdrom floppy snd_pcm snd_timer serio_raw snd_page_alloc ohci1394 snd_hwdep ieee1394 sky2 snd soundcore joydev button wmi evdev sg raid456 async_xor async_memcpy async_tx xor raid0 usbhid ff_memless ehci_hcd ohci_hcd sd_mod edd raid1 ext3 jbd fan pata_marvell pata_atiixp thermal processor
Pid: 2264, comm: kjournald Not tainted 2.6.26-git #203

Call Trace:
 [<ffffffff8023aadf>] warn_on_slowpath+0x5f/0x80
 [<ffffffff80261075>] ? __lock_acquire+0x8d5/0x1290
 [<ffffffff8028991b>] ? mempool_alloc+0x5b/0x140
 [<ffffffff8034e43b>] blk_plug_device+0x9b/0xb0
 [<ffffffff8044727f>] bitmap_startwrite+0xbf/0x1b0
 [<ffffffff802dff44>] ? bio_alloc_bioset+0x54/0xb0
 [<ffffffffa004ea9c>] make_request+0x39c/0x810 [raid1]
 [<ffffffff8028991b>] ? mempool_alloc+0x5b/0x140
 [<ffffffff8028991b>] ? mempool_alloc+0x5b/0x140
 [<ffffffff8034d68d>] generic_make_request+0x17d/0x2b0
 [<ffffffff8034f03c>] submit_bio+0x6c/0xf0
 [<ffffffff802db3c0>] submit_bh+0xf0/0x130
 [<ffffffffa001cce0>] journal_commit_transaction+0xa40/0x1000 [jbd]
 [<ffffffff80245c74>] ? try_to_del_timer_sync+0x44/0x90
 [<ffffffffa0020947>] kjournald+0xe7/0x250 [jbd]
 [<ffffffff80251a60>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa0020860>] ? kjournald+0x0/0x250 [jbd]
 [<ffffffff8025160d>] kthread+0x4d/0x80
 [<ffffffff8020c6c9>] child_rip+0xa/0x11
 [<ffffffff8020bcff>] ? restore_args+0x0/0x30
 [<ffffffff802515c0>] ? kthread+0x0/0x80
 [<ffffffff8020c6bf>] ? child_rip+0x0/0x11

---[ end trace a367ac91f145af0b ]---

dmesg: http://www.sisk.pl/kernel/debug/mainline/a3cf859321486f69506326146ab3e2fd15c05c3f/dmesg-M3A32-MVP.log
config: http://www.sisk.pl/kernel/debug/mainline/a3cf859321486f69506326146ab3e2fd15c05c3f/M3A32-MVP-config

Thanks,
Rafael
