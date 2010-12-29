From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: dm9000 patch
Date: Wed, 29 Dec 2010 20:06:51 +0200
Message-ID: <20101229180650.GE6067@tarshish>
References: <4D1A5C2A.5050606@gmail.com>
 <20101229060637.GA31010@jasper.tkos.co.il>
 <4D1B33F2.5060600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: Angelo Dureghello <angelo70@gmail.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D1B33F2.5060600@gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Angelo,

On Wed, Dec 29, 2010 at 02:13:22PM +0100, Angelo Dureghello wrote:
> just FYI, i tested kernel 2.6.36.2, unfortunately the issue is still
> there, below the call stack trace.

Help from the m68k experts seems to be needed. Adding the relevant list to Cc.

baruch

> [    4.620000] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
> [   39.390000] BUG: spinlock recursion on CPU#0, httpd/29
> [   39.390000]  lock: 00189c44, .magic: dead4ead, .owner: httpd/29,
> .owner_cpu: 0
> [   39.390000] Stack from 00d6a990:
> [   39.390000]         00d6a9bc 000a9710 0017cac7 00189c44 dead4ead
> 00de48f4 0000001d 00000000
> [   39.390000]         00189c44 0002a646 00145f70 00d6a9f0 000a98e2
> 00189c44 0017cb2d 00189c44
> [   39.390000]         00d6aad8 0000001f 00145f5c 001523f6 00189c08
> 0002a646 00145f70 0002bc52
> [   39.390000]         00d6a9fc 00145f7e 00189c44 00d6aa28 0002a75e
> 00189c44 0000001f 00d6aad8
> [   39.390000]         0000001f 00145f5c 00189c08 0002a646 00145f70
> 0002bc52 00d6aa3c 00000bb6
> [   39.390000]         0000001f 00189c44 00cfc780 00d6aa84 0000337a
> 0000001f 00d6aa4c 00000001
> [   39.390000] Call Trace:
> [   39.390000]  [000a9710] spin_bug+0x86/0x11a
> [   39.390000]  [000a98e2] do_raw_spin_lock+0x58/0x120
> [   39.390000]  [00145f7e] _raw_spin_lock+0xe/0x14
> [   39.390000]  [0002a75e] __do_IRQ+0x2c/0x108
> [   39.390000]  [00000bb6] do_IRQ+0x48/0x62
> [   39.390000]  [0000337a] inthandler+0x6a/0x74
> [   39.390000]  [0002a82e] __do_IRQ+0xfc/0x108
> [   39.390000]  [00000bb6] do_IRQ+0x48/0x62
> [   39.390000]  [0000337a] inthandler+0x6a/0x74
> [   39.390000]  [000ef0ce] skb_release_all+0x10/0x20
> [   39.390000]  [000ee6bc] __kfree_skb+0x10/0x92
> [   39.390000]  [000ee75e] consume_skb+0x20/0x34
> [   39.390000]  [000e004e] dm9000_start_xmit+0xdc/0xec
> [   39.390000]  [000f67a2] dev_hard_start_xmit+0x146/0x472
> [   39.390000]  [00106506] sch_direct_xmit+0xc0/0x1bc
> [   39.390000]  [000f9914] dev_queue_xmit+0x160/0x3e4
> [   39.390000]  [00113b3e] ip_finish_output+0xee/0x318
> [   39.390000]  [001142b4] ip_output+0x7c/0x88
> [   39.390000]  [00113dc6] ip_local_out+0x26/0x30
> [   39.390000]  [00114d9a] ip_queue_xmit+0x152/0x374
> [   39.390000]  [00125c8c] tcp_transmit_skb+0x3f0/0x732
> [   39.390000]  [00126f26] tcp_write_xmit+0x178/0x868
> [   39.390000]  [00127644] __tcp_push_pending_frames+0x2e/0x9a
> [   39.390000]  [0011c3d6] tcp_sendmsg+0x82e/0x98c
> [   39.390000]  [00137544] inet_sendmsg+0x32/0x54
> [   39.390000]  [000e79a6] sock_aio_write+0xc8/0x138
> [   39.390000]  [00042590] do_sync_write+0x9e/0xfe
> [   39.390000]  [00042668] vfs_write+0x78/0x84
> [   39.390000]  [00042a92] sys_write+0x40/0x7a
> [   39.390000]  [00003224] system_call+0x84/0xc2
> [   39.390000]
> 
> dm9000e is as default not visible/selectable in menuconfig for
> Coldfire architectures, so this probably cannot be considered as a
> kernel bug.
> 
> I going forward in investigations, every help is appreciated,
> 
> regards,
> angelo
> 
> 
> 
> On 29/12/2010 07:06, Baruch Siach wrote:
> >Hi Angelo,
> >
> >On Tue, Dec 28, 2010 at 10:52:42PM +0100, Angelo Dureghello wrote:
> >>sorry to contact you directly but i couldn't get any help from the
> >>kernel.org mailing list, since i am not a developer my mails are
> >>generally skipped.
> >The best way to get the contact info for a piece of kernel code, is using the
> >get_maintainer.pl script. Running 'scripts/get_maintainer.pl -f
> >drivers/net/dm9000.c' gives the following output:
> >
> >netdev@vger.kernel.org
> >linux-kernel@vger.kernel.org
> >
> >I added both to Cc.
> >
> >>I am very near to have a custom board working with MCF5307 cpu and dm9000.
> >>I am using kernel 2.6.36-rc3 with your last patch about
> >>spinlock-recursion already included.
> >You should try to update to the latest .36 kernel, which is currently
> >2.6.36.2. The problem that you experience might be unrelated to the dm9000
> >driver (or to networking at all), so it might have been fixed in this version.
> >
> >>I have "ping" and "telnet" to the embedded board fully working.
> >>If i try to get a sample web page with some images from the board
> >>httpd with a browser, in 80% of cases i get a trap/oops:
> >Try to enable KALLSYMS in your kernel .config to make your stack trace more
> >meaningful. This is under 'General setup ->  Configure standard kernel features
> >(for small systems) ->  Load all symbols for debugging/ksymoops'.
> >
> >I hope this helps.
> >
> >baruch
> >
> >>[    4.590000] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
> >>[   67.630000] BUG: spinlock recursion on CPU#0, httpd/29
> >>[   67.630000]  lock: 00c42c06, .magic: dead4ead, .owner: httpd/29,
> >>.owner_cpu: 0
> >>[   67.630000] Stack from 00d7b914:
> >>[   67.630000]         00d7b940 000a8cf0 0015f693 00c42c06 dead4ead
> >>00dec1d4 0000001d 00000000
> >>[   67.630000]         00c42c06 00006188 00c42800 00d7b974 000a8ec2
> >>00c42c06 0015f6f9 00002704
> >>[   67.630000]         00000000 0000001f 00146fa4 00152f0c 00c42b60
> >>00006188 00c42800 0002b312
> >>[   67.630000]         00d7b984 0014701e 00c42c06 00000000 00d7b9c4
> >>000df21c 00c42c06 00000000
> >>[   67.630000]         00000000 0000001f 00146fa4 00152f0c 000005ea
> >>00cfc640 00006188 000096e8
> >>[   67.630000]         0002b312 00146fa4 00c42b60 00002704 00d7b9ec
> >>00029d3a 0000001f 00c42800
> >>[   67.630000] Call Trace:
> >>[   67.630000]  [000a8cf0]  [000a8ec2]  [0014701e]  [000df21c]  [00029d3a]
> >>[   67.630000]  [00029e84]  [00000bb6]  [0000336e]  [000df162]  [000effd6]
> >>[   67.630000]  [00100482]  [000f312e]  [000f9ebc]  [0010dd2a]  [0010e4a0]
> >>[   67.630000]  [0010dfb2]  [0010ef80]  [0011fed6]  [00121170]  [0012188e]
> >>[   67.630000]  [0011ecc6]  [001249fe]  [000e4084]  [0011621c]  [00131a44]
> >>[   67.630000]  [000e11ee]  [00041944]  [00041a1c]  [00041e46]  [00003218]
> >>[   67.630000] BUG: spinlock lockup on CPU#0, httpd/29, 00c42c06
> >>[   67.630000] Stack from 00d7b934:
> >>[   67.630000]         00d7b974 000a8f66 0015f703 00000000 00dec1d4
> >>0000001d 00c42c06 00002704
> >>[   67.630000]         00000000 0000001f 00146fa4 00152f0c 00c42b60
> >>00006188 00c42800 0002b312
> >>[   67.630000]         00d7b984 0014701e 00c42c06 00000000 00d7b9c4
> >>000df21c 00c42c06 00000000
> >>[   67.630000]         00000000 0000001f 00146fa4 00152f0c 000005ea
> >>00cfc640 00006188 000096e8
> >>[   67.630000]         0002b312 00146fa4 00c42b60 00002704 00d7b9ec
> >>00029d3a 0000001f 00c42800
> >>[   67.630000]         0016c1b4 00cfc640 0000001f 0016c178 00029d10
> >>00146fb8 00d7ba20 00029e84
> >>[   67.630000] Call Trace:
> >>[   67.630000]  [000a8f66]  [0014701e]  [000df21c]  [00029d3a]  [00029e84]
> >>[   67.630000]  [00000bb6]  [0000336e]  [000df162]  [000effd6]  [00100482]
> >>[   67.630000]  [000f312e]  [000f9ebc]  [0010dd2a]  [0010e4a0]  [0010dfb2]
> >>[   67.630000]  [0010ef80]  [0011fed6]  [00121170]  [0012188e]  [0011ecc6]
> >>[   67.630000]  [001249fe]  [000e4084]  [0011621c]  [00131a44]  [000e11ee]
> >>[   67.630000]  [00041944]  [00041a1c]  [00041e46]  [00003218]
> >>
> >>As i said, i was hoping in your patch but i sadly discovered it is
> >>already included in this kernel version.
> >>Hope you can give me some help or can forward me to an appropriate
> >>mailing list.
> 

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
