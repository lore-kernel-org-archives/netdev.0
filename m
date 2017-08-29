From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Tue, 29 Aug 2017 12:59:00 +0200
Message-ID: <CAMuHMdUefXtqv9bFfgrkbu8NZRXeTD6qR-nErf6TCDz4L+OAWw@mail.gmail.com>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Samuel Ortiz <samuel@sortiz.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        driverdevel <devel@driverdev.osuosl.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

On Sun, Aug 27, 2017 at 5:03 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> The IRDA code has long been obsolete and broken.  So, to keep people
> from trying to use it, and to prevent people from having to maintain it,
> let's move it to drivers/staging/ so that we can delete it entirely from
> the kernel in a few releases.

(diving into an early boot crash)

Have you tried running this? ;-)

irda_init() and net_dev_init() are both subsys_initcall()s.
But the former now runs before the latter, leading to:

Unable to handle kernel NULL pointer dereference at virtual address 00000004
pgd = c0004000
[00000004] *pgd=00000000
Internal error: Oops: 5 [#1] SMP ARM
Modules linked in:
CPU: 1 PID: 1 Comm: swapper/0 Not tainted
4.13.0-rc7-kzm9g-05769-g46efec19d1294ece-dirty #954
Hardware name: Generic SH73A0 (Flattened Device Tree)
task: df440040 task.stack: df442000
PC is at __list_add_valid+0x8/0x74
LR is at 0x0
pc : [<c03223ec>]    lr : [<00000000>]    psr: 60000013
sp : df443ef0  ip : df440630  fp : 00000000
r10: c0828858  r9 : c0937000  r8 : 00000000
r7 : c0908034  r6 : 00000000  r5 : c0908020  r4 : c090862c
r3 : df440040  r2 : 00000000  r1 : c090862c  r0 : c0908034
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5387d  Table: 4000404a  DAC: 00000051
Process swapper/0 (pid: 1, stack limit = 0xdf442210)
Stack: (0xdf443ef0 to 0xdf444000)
3ee0:                                     c090862c c0489ea8 00000000 00000000
3f00: c081c274 00000093 c0836418 c081c2a0 00000004 c0101878 00000000 c0790758
3f20: 00000000 c013fec0 00000001 c078fbf0 00000004 00000004 c079076c dfffce3f
3f40: 00000092 c079076c dfffce3f dfffce47 c0910af0 00000004 c0828844 00000093
3f60: 00000004 c0828848 00000093 c0836418 c0937000 c0800d28 00000004 00000004
3f80: 00000000 c08005b0 00000000 c055cf7c 00000000 00000000 00000000 00000000
3fa0: 00000000 c055cf84 00000000 c0106f90 00000000 00000000 00000000 00000000
3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 7fdfffff fff7fdff
[<c03223ec>] (__list_add_valid) from [<c0489ea8>] (dev_add_pack+0x70/0xac)
[<c0489ea8>] (dev_add_pack) from [<c081c2a0>] (irda_init+0x2c/0x84)
[<c081c2a0>] (irda_init) from [<c0101878>] (do_one_initcall+0xa8/0x150)
[<c0101878>] (do_one_initcall) from [<c0800d28>]
(kernel_init_freeable+0x114/0x1d4)
[<c0800d28>] (kernel_init_freeable) from [<c055cf84>] (kernel_init+0x8/0x110)
[<c055cf84>] (kernel_init) from [<c0106f90>] (ret_from_fork+0x14/0x24)

DIsabling CONFIG_IRDA (apparently I wasn't using it anyway), and
continuing my life...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
