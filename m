From: Grzegorz Kulewski <kangur@polcom.net>
Subject: network related(?) kernel panic (2.6.7-bk4)
Date: Mon, 21 Jun 2004 23:49:48 +0200 (CEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.58.0406212345400.15660@alpha.polcom.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com,
	akpm@osdl.org, kangur@polcom.net
Return-path: <linux-net-owner@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
List-Id: netdev.vger.kernel.org

I have sent this to LKML but I forward it to you.

Hi,

I am testing 2.6.7-bk4 + timer fix + vesafb-tng patch. This time without 
debuging compiled in. Everything worked perfectly before I got:

bad: scheduling while atomic!
schedule+0x466/0x470
do_page_fault+0x104/0x4c1
ip_route_output_flow+0x22/0x70
sys_sched_yield+0x3f/0x50
coredump_wait+0x31/0xa0
do_coredump+0xf1/0x1af
sockfd_lookup+0x16/0x80
do_page_fault+0x0/0x4c1
error_code+0x2d/0x38
__dequeue_signal+0xc6/0x160
dequeue_signal+0x23/0x80
get_signal_to_deriver+0x246/0x330
do_signal+0x85/0x100
__sock_create+0x191/0x260
sys_send+0x37/0x40
sys_socketcall+0x12f/0x250
copy_to_user+0x32/0x50
do_page_fault+0x0/0x4c1
do_notify_resume+0x35/0x38
work_notifysig+0x13/0x15
Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing

(sorry for any mistakes - I copied it by hand).

The kernel was not tainted. I can reproduce the same every time I want to 
connect to the network. I use speedtouch kernel driver. I have script that 
first executes modem_run then pppd then wget to change DNS entries to new 
IP adress. This happens after pppd setups connection and gets IP. I think 
that this happens in wget. This works with 2.6.7, so some recent bk change 
is probably the cause.

Can you help me?


Thanks,

Grzegorz Kulewski

