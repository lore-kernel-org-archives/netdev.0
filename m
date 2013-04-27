From: bvba Bart Van Assche <info@bartvanassche.be>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from spin_lock_mutex
Date: Sat, 27 Apr 2013 20:53:54 +0200
Message-ID: <517C1EC2.5090900@bartvanassche.be>
References: <20130423132345.GA5564@hmsreliant.think-freely.org> <CAO+b5-rQPyO9QE9v+oQTeo+G-ftcsehSB5=63AZ13QW4EJ1X0Q@mail.gmail.com> <20130423134443.GB5564@hmsreliant.think-freely.org> <20130423.133315.1278191592594257624.davem@davemloft.net> <20130423175016.GC5564@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mingo@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:38651 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab3D0Sx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 14:53:58 -0400
In-Reply-To: <20130423175016.GC5564@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/13 19:50, Neil Horman wrote:
> On Tue, Apr 23, 2013 at 01:33:15PM -0400, David Miller wrote:
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Tue, 23 Apr 2013 09:44:43 -0400
>>
>>> Dave, how do you feel about it?  I'm comfortable with the wait queue change I've
>>> proposed, but I've not received any reports of actual netpoll deadlocks (i.e.
>>> the mutex solution is reporting a warning, but no actual problems).  So I think
>>> its safe to wait a bit longer, unless you just want this squared away now.
>>
>> If it's just a warning and people aren't actually hitting the
>> potential deadlock, it can wait.
>>
> Copy that. Bart, I'll wait till you get back then.

(Just arrived home)

Sorry Neil, but I can still trigger the CPU stuck messages with kernel v3.9-rc8-24-gd7d7271:

kernel: BUG: soft lockup - CPU#0 stuck for 22s! [rs:main Q:Reg:601]
kernel: irq event stamp: 1999192
kernel: hardirqs last  enabled at (1999191): [<ffffffff8103e89d>] console_unlock+0x41d/0x450
kernel: hardirqs last disabled at (1999192): [<ffffffff8143e96a>] apic_timer_interrupt+0x6a/0x80
kernel: softirqs last  enabled at (1999188): [<ffffffff81044e26>] __do_softirq+0x196/0x280
kernel: softirqs last disabled at (1999181): [<ffffffff810450c5>] irq_exit+0xb5/0xc0
kernel: CPU 0 
kernel: Pid: 601, comm: rs:main Q:Reg Tainted: G           O 3.9.0-rc8-debug+ #1 System manufacturer P5Q DELUXE/P5Q DELUXE
kernel: RIP: 0010:[<ffffffff8103e8a0>]  [<ffffffff8103e8a0>] console_unlock+0x420/0x450
kernel: Call Trace:
kernel: [<ffffffff812bbf37>] do_con_write.part.19+0x887/0x2040
kernel: [<ffffffff812a52b7>] ? process_output+0x37/0x70
kernel: [<ffffffff814316fc>] ? mutex_lock_nested+0x28c/0x350
kernel: [<ffffffff812a52b7>] ? process_output+0x37/0x70
kernel: [<ffffffff812bd764>] con_write+0x34/0x50
kernel: [<ffffffff812a51e9>] do_output_char+0x179/0x210
kernel: [<ffffffff812a52cd>] process_output+0x4d/0x70
kernel: [<ffffffff812a59d0>] n_tty_write+0x210/0x480
kernel: [<ffffffff81072710>] ? try_to_wake_up+0x2e0/0x2e0
kernel: [<ffffffff812a2839>] tty_write+0x159/0x300
kernel: [<ffffffff8109326f>] ? lock_release_holdtime.part.22+0xf/0x180
kernel: [<ffffffff812a57c0>] ? n_tty_poll+0x1c0/0x1c0
kernel: [<ffffffff81151a3b>] vfs_write+0xab/0x170
kernel: [<ffffffff81151ea5>] sys_write+0x55/0xa0
kernel: [<ffffffff8143dd82>] system_call_fastpath+0x16/0x1b

Bart.
