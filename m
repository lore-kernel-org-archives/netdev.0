From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: [BUG][mvebu] mvneta: cannot request irq 25 on openblocks-ax3
Date: Tue, 19 Mar 2013 22:12:37 +0900
Message-ID: <51486445.8040506@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>
To: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com,
	Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here I've hit a bug on the recent kernel. As far as I know, this bug
exists on 3.9-rc1 too.

When I tried the latest mvebu for-next tree
(git://git.infradead.org/users/jcooper/linux.git mvebu/for-next),
I got below warning at bootup time and mvneta didn't work (link was never up).
I ensured that "ifconfig ethX up" always caused that.

Does anyone succeed to boot openblocks-ax3 recently or hit same
trouble?

------------[ cut here ]------------
WARNING: at /ssd/ksrc/linux-3/kernel/irq/manage.c:1417
request_threaded_irq+0x64/0x124()
Modules linked in:
Backtrace:
[<c00119a4>] (dump_backtrace+0x0/0x110) from [<c04b2bac>] (dump_stack+0x18/0x1c)
 r6:c05ad11a r5:00000589 r4:00000000 r3:ed80e000
[<c04b2b94>] (dump_stack+0x0/0x1c) from [<c0021484>]
(warn_slowpath_common+0x54/0x70)
[<c0021430>] (warn_slowpath_common+0x0/0x70) from [<c00214c4>]
(warn_slowpath_null+0x24/0x2c)
 r8:00000000 r7:ef0a4600 r6:ee9c4d40 r5:00000000 r4:c037378c
r3:00000009
[<c00214a0>] (warn_slowpath_null+0x0/0x2c) from [<c0084bb8>]
(request_threaded_irq+0x64/0x124)
[<c0084b54>] (request_threaded_irq+0x0/0x124) from [<c037418c>]
(mvneta_open+0x80/0x15c)
[<c037410c>] (mvneta_open+0x0/0x15c) from [<c03c9e3c>] (__dev_open+0xa0/0xf4)
 r6:00001002 r5:c050bb24 r4:ee9c4800
[<c03c9d9c>] (__dev_open+0x0/0xf4) from [<c03ca070>] (__dev_change_flags+0x94/0x118)
 r7:00000001 r6:00001002 r5:00001003 r4:ee9c4800
[<c03c9fdc>] (__dev_change_flags+0x0/0x118) from [<c03ca170>]
(dev_change_flags+0x18/0x4c)
 r7:00000000 r6:edd0d380 r5:00001002 r4:ee9c4800
[<c03ca158>] (dev_change_flags+0x0/0x4c) from [<c03d6168>] (do_setlink+0x2a4/0x7a0)
 r6:edd0d380 r5:ed80fb4c r4:ee9c4800 r3:00001002
[<c03d5ec4>] (do_setlink+0x0/0x7a0) from [<c03d72d8>] (rtnl_newlink+0x248/0x45c)
[<c03d7090>] (rtnl_newlink+0x0/0x45c) from [<c03d7060>]
(rtnetlink_rcv_msg+0x248/0x278)
[<c03d6e18>] (rtnetlink_rcv_msg+0x0/0x278) from [<c03ead78>]
(netlink_rcv_skb+0x58/0xb4)
[<c03ead20>] (netlink_rcv_skb+0x0/0xb4) from [<c03d5d28>] (rtnetlink_rcv+0x20/0x2c)
 r6:eea75c00 r5:eea87240 r4:eea87240 r3:c03d5d08
[<c03d5d08>] (rtnetlink_rcv+0x0/0x2c) from [<c03ea780>]
(netlink_unicast+0x15c/0x214)
 r4:ef0a3000 r3:c03d5d08
[<c03ea624>] (netlink_unicast+0x0/0x214) from [<c03eab94>]
(netlink_sendmsg+0x2b8/0x348)
[<c03ea8dc>] (netlink_sendmsg+0x0/0x348) from [<c03b2dbc>] (sock_sendmsg+0x88/0xa4)
[<c03b2d34>] (sock_sendmsg+0x0/0xa4) from [<c03b3330>] (__sys_sendmsg+0x1c8/0x25c)
 r7:00000000 r6:00000020 r5:eefccc80 r4:ed80ff64
[<c03b3168>] (__sys_sendmsg+0x0/0x25c) from [<c03b4f30>] (sys_sendmsg+0x44/0x68)
[<c03b4eec>] (sys_sendmsg+0x0/0x68) from [<c000daa0>] (ret_fast_syscall+0x0/0x30)
 r6:be9f367c r5:00000000 r4:5146f675
---[ end trace a8ceb54233e388b5 ]---
mvneta d0070000.ethernet eth0: cannot request irq 25

Thank you,
-- 
Masami HIRAMATSU
IT Management Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
