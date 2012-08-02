From: "George Spelvin" <linux@horizon.com>
Subject: Re: v3.5: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: 2 Aug 2012 09:32:00 -0400
Message-ID: <20120802133200.20698.qmail@science.horizon.com>
References: <20120801232953.3791.qmail@science.horizon.com>
Cc: linux@horizon.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:11973 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754056Ab2HBNcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 09:32:04 -0400
In-Reply-To: <20120801232953.3791.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My, that was exciting.

I rebooted with the drastic timeout reduction I proposed last night.
(Actuallly, I compiled a version before I realized TSO could increase the
output size, so it was set to (HZ/150) = 2 jiffies.)

Anyway, it worked fine last night, and *didn't* display the NETDEV
WATCHDOG warning on reboot.

But this morning at uptime 12 hours, (and as the office was filling up
in the morning, although there certainly was *some* traffic overnight),
things went pear-shaped:

Aug  2 12:45:11: ------------[ cut here ]------------
Aug  2 12:45:11: WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xe9/0x154()
Aug  2 12:45:11: Hardware name: MS-7376
Aug  2 12:45:11: NETDEV WATCHDOG: inside (r8169): transmit queue 0 timed out
Aug  2 12:45:11: Pid: 0, comm: swapper/3 Not tainted 3.5.0-00021-gc432f46 #162
Aug  2 12:45:11: Call Trace:
Aug  2 12:45:11: <IRQ>  [<ffffffff8131d2c2>] ? dev_watchdog+0xe9/0x154
Aug  2 12:45:11: [<ffffffff810254c9>] ? warn_slowpath_common+0x71/0x85
Aug  2 12:45:11: [<ffffffff8131d1d9>] ? netif_tx_lock+0x7a/0x7a
Aug  2 12:45:11: [<ffffffff81025541>] ? warn_slowpath_fmt+0x45/0x4a
Aug  2 12:45:11: [<ffffffff8103cf28>] ? hrtimer_interrupt+0x100/0x1a4
Aug  2 12:45:11: [<ffffffff8131d1c6>] ? netif_tx_lock+0x67/0x7a
Aug  2 12:45:11: [<ffffffff8131d2c2>] ? dev_watchdog+0xe9/0x154
Aug  2 12:45:11: [<ffffffff8104e800>] ? clockevents_program_event+0x9a/0xb6
Aug  2 12:45:11: [<ffffffff8102ea43>] ? run_timer_softirq+0x17e/0x20b
Aug  2 12:45:11: [<ffffffff8102a9b1>] ? __do_softirq+0x80/0x102
Aug  2 12:45:11: [<ffffffff81411f4c>] ? call_softirq+0x1c/0x30
Aug  2 12:45:11: [<ffffffff810032f4>] ? do_softirq+0x2c/0x60
Aug  2 12:45:11: [<ffffffff8102abe4>] ? irq_exit+0x3a/0x91
Aug  2 12:45:11: [<ffffffff81003141>] ? do_IRQ+0x81/0x97
Aug  2 12:45:11: [<ffffffff81410567>] ? common_interrupt+0x67/0x67
Aug  2 12:45:11: <EOI>  [<ffffffff81007d63>] ? default_idle+0x1e/0x32
Aug  2 12:45:11: [<ffffffff81007e87>] ? amd_e400_idle+0xb7/0xd4
Aug  2 12:45:11: [<ffffffff81008501>] ? cpu_idle+0x58/0x98
Aug  2 12:45:11: ---[ end trace d46f8d5c6451870e ]---
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: net_ratelimit: 255 callbacks suppressed
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: net_ratelimit: 258 callbacks suppressed
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: net_ratelimit: 262 callbacks suppressed
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: net_ratelimit: 262 callbacks suppressed
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: net_ratelimit: 259 callbacks suppressed
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: net_ratelimit: 261 callbacks suppressed
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: net_ratelimit: 248 callbacks suppressed
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: net_ratelimit: 248 callbacks suppressed
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: net_ratelimit: 258 callbacks suppressed
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:45:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: net_ratelimit: 258 callbacks suppressed
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: net_ratelimit: 252 callbacks suppressed
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: net_ratelimit: 253 callbacks suppressed
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: net_ratelimit: 260 callbacks suppressed
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: net_ratelimit: 261 callbacks suppressed
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:21: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: net_ratelimit: 269 callbacks suppressed
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:26: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: net_ratelimit: 263 callbacks suppressed
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:31: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: net_ratelimit: 260 callbacks suppressed
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:36: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: net_ratelimit: 266 callbacks suppressed
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:41: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: net_ratelimit: 254 callbacks suppressed
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:46: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: net_ratelimit: 257 callbacks suppressed
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:51: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:52: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:52: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:56: net_ratelimit: 257 callbacks suppressed
Aug  2 12:46:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:56: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:57: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:57: r8169 0000:02:00.0: inside: link up
Aug  2 12:46:57: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:01: net_ratelimit: 246 callbacks suppressed
Aug  2 12:47:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:01: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:02: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:02: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:02: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:02: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:06: net_ratelimit: 265 callbacks suppressed
Aug  2 12:47:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:06: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:07: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:07: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:07: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:07: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:07: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:07: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:11: net_ratelimit: 252 callbacks suppressed
Aug  2 12:47:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:11: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:12: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:16: net_ratelimit: 254 callbacks suppressed
Aug  2 12:47:16: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:17: r8169 0000:02:00.0: inside: link up

# The following is me trying "ifconfig down" and "ip link set up" from
# the console to try to restart things.  First attempts didn't work, but
# something seems to have fixed it not long after.

Aug  2 12:47:18: r8169 0000:02:00.0: inside: link down
Aug  2 12:47:18: r8169 0000:02:00.0: inside: link down
Aug  2 12:47:18: IPv6: ADDRCONF(NETDEV_UP): inside: link is not ready
Aug  2 12:47:18: r8169 0000:02:00.0: inside: link down
Aug  2 12:47:21: IPv6: ADDRCONF(NETDEV_CHANGE): inside: link becomes ready
Aug  2 12:47:21: net dmz: Setting full-duplex based on MII#1 link partner capability of 45e1
Aug  2 12:47:21: net cable: Setting full-duplex based on MII#1 link partner capability of 41e1
Aug  2 12:47:37: r8169 0000:02:00.0: inside: link down
Aug  2 12:47:37: r8169 0000:02:00.0: inside: link down
Aug  2 12:47:37: IPv6: ADDRCONF(NETDEV_UP): inside: link is not ready
Aug  2 12:47:39: net_ratelimit: 58 callbacks suppressed
Aug  2 12:47:39: r8169 0000:02:00.0: inside: link up
Aug  2 12:47:39: IPv6: ADDRCONF(NETDEV_CHANGE): inside: link becomes ready
Aug  2 12:47:40: net dmz: Setting full-duplex based on MII#1 link partner capability of 45e1
Aug  2 12:47:40: net cable: Setting full-duplex based on MII#1 link partner capability of 41e1


After it came back, I did a few simple stress tests, which it survived just fine:
ping -c 1000000 -l 50 -f:
1000000 packets transmitted, 1000000 received, 0% packet loss, time 14503ms
rtt min/avg/max/mdev = 0.043/0.138/0.686/0.053 ms, pipe 50, ipg/ewma 0.014/0.102 ms

ping -s 1472 -c 1000000 -l 50 -f:
1000000 packets transmitted, 1000000 received, 0% packet loss, time 30672ms
rtt min/avg/max/mdev = 0.156/0.330/1.364/0.055 ms, pipe 50, ipg/ewma 0.030/0.350 ms

4 GiB of wire-speed copy from /dev/zero to /dev/null (dd bs=65536 count=65536 | nc):
4294967296 bytes (4.3 GB) copied, 36.6281 s, 117 MB/s


Very odd.  I'm posting this in case it is of any debugging assistance.
