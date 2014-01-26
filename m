From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: WARNING: at net/ipv4/devinet.c:1599
Date: Sun, 26 Jan 2014 10:56:24 +0100
Message-ID: <CAMuHMdWFDhTXaTTgBHg1hVduBKU2+Liz9j+ZHd=kBFh3hhTGhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On m68k/ARAnyM:

WARNING: CPU: 0 PID: 407 at net/ipv4/devinet.c:1599 0x316a99()
Modules linked in:
CPU: 0 PID: 407 Comm: ifconfig Not tainted
3.13.0-atari-09263-g0c71d68014d1 #1378
Stack from 10c4fdf0:
        10c4fdf0 002ffabb 000243e8 00000000 008ced6c 00024416 00316a99 0000063f
        00316a99 00000009 00000000 002501b4 00316a99 0000063f c0a86117 00000080
        c0a86117 00ad0c90 00250a5a 00000014 00ad0c90 00000000 00000000 00000001
        00b02dd0 00356594 00000000 00356594 c0a86117 eff6c9e4 008ced6c 00000002
        008ced60 0024f9b4 00250b52 00ad0c90 00000000 00000000 00252390 00ad0c90
        eff6c9e4 0000004f 00000000 00000000 eff6c9e4 8000e25c eff6c9e4 80001020
Call Trace: [<000243e8>] warn_slowpath_common+0x52/0x6c
 [<00024416>] warn_slowpath_null+0x14/0x1a
 [<002501b4>] rtmsg_ifa+0xdc/0xf0
 [<00250a5a>] __inet_insert_ifa+0xd6/0x1c2
 [<0024f9b4>] inet_abc_len+0x0/0x42
 [<00250b52>] inet_insert_ifa+0xc/0x12
 [<00252390>] devinet_ioctl+0x2ae/0x5d6
 [<00020000>] _060_fpsp_effadd+0xc90c/0xd518
 [<00020000>] _060_fpsp_effadd+0xc90c/0xd518
 [<002530ec>] inet_ioctl+0x120/0x14e
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<001f7666>] sock_ioctl+0x56/0x256
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<00095434>] vfs_ioctl+0x1c/0x30
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<0009559c>] do_vfs_ioctl+0x7a/0x3b8
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<00002884>] buserr+0x20/0x28
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<00095910>] SyS_ioctl+0x36/0x5a
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<00002980>] syscall+0x8/0xc
 [<00008916>] atari_scc_console_write+0x42/0x5c
 [<0010c00b>] mext_leaf_block+0x443/0x81e

---[ end trace 44b14c97c2210758 ]---

Adding some debugging code reveals that net_fill_ifaddr() fails in

    put_cacheinfo(skb, ifa->ifa_cstamp, ifa->ifa_tstamp,
                              preferred, valid))

nla_put complains:

lib/nlattr.c:454: skb_tailroom(skb) = 12, nla_total_size(attrlen) = 20

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
