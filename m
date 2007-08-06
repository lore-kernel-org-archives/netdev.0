From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 6 Aug 2007 08:58:45 +0200
Message-ID: <4bacf17f0708052358od2f8e1dv1d5bde51209f155d@mail.gmail.com>
References: <1185322771.4175.102.camel@chaos>
	 <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos>
	 <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local>
	 <20070726091254.GA8063@elte.hu>
	 <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
	 <20070730084925.GA12695@elte.hu>
	 <4bacf17f0708010024r3abc196dv4d6924e314536b17@mail.gmail.com>
	 <20070801072741.GA21551@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:23080 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914AbXHFG6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 02:58:47 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1687678wah
        for <netdev@vger.kernel.org>; Sun, 05 Aug 2007 23:58:46 -0700 (PDT)
In-Reply-To: <20070801072741.GA21551@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/1, Ingo Molnar <mingo@elte.hu>:
> ok, it wasnt supposed to be _that_ easy i guess :-) Can you please
> (re-)confirm that the workaround below indeed fixes the hung card
> problem? (after producing a single WARN_ON message into the syslog)
yes, with this patch everything works fine

end of dmesg:

EXT3 FS on sda7, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 1020112k swap on /dev/sda2.  Priority:-1 extents:1 across:1020112k
skge eth1: enabling interface
NET: Registered protocol family 17
WARNING: at kernel/irq/resend.c:70 check_irq_resend()

Call Trace:
 [<ffffffff8025e5c8>] check_irq_resend+0xa8/0xc0
 [<ffffffff8025e1ca>] enable_irq+0xea/0xf0
 [<ffffffff8800f21d>] :8390:ei_start_xmit+0x14d/0x30c
 [<ffffffff8052b5ce>] dev_hard_start_xmit+0x26e/0x2d0
 [<ffffffff80539b10>] __qdisc_run+0xc0/0x1f0
 [<ffffffff8052db9f>] dev_queue_xmit+0x24f/0x310
 [<ffffffff880d7ac9>] :af_packet:packet_sendmsg+0x259/0x2c0
 [<ffffffff8051f0bf>] sock_sendmsg+0xdf/0x110
 [<ffffffff8024b8c9>] trace_hardirqs_on+0xd9/0x180
 [<ffffffff8024c1dd>] __lock_acquire+0x31d/0xff0
 [<ffffffff80243290>] autoremove_wake_function+0x0/0x40
 [<ffffffff803e3103>] __up_read+0x23/0xb0
 [<ffffffff803e3125>] __up_read+0x45/0xb0
 [<ffffffff805bd8f5>] _spin_unlock_irqrestore+0x65/0x80
 [<ffffffff8024b8c9>] trace_hardirqs_on+0xd9/0x180
 [<ffffffff803e3125>] __up_read+0x45/0xb0
 [<ffffffff802464b6>] up_read+0x26/0x30
 [<ffffffff8051f4f1>] sys_sendto+0x111/0x150
 [<ffffffff8024b8c9>] trace_hardirqs_on+0xd9/0x180
 [<ffffffff805bd93b>] _spin_unlock_irq+0x2b/0x60
 [<ffffffff8023861a>] do_sigaction+0x11a/0x1d0
 [<ffffffff802097fe>] system_call+0x7e/0x83

Marking TSC unstable due to cpufreq changes
Time: acpi_pm clocksource has been installed.

> also, does removing the ne2k-pci module and reinserting it again solve
> the problem too, or is your network card stuck forever once it got into
> that state?
it doesn't change anything - i tried reloading both modules (ne2k_pci and skge)

Marcin
