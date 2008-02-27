From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
Date: Wed, 27 Feb 2008 11:29:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
 <20080223000310.4630daa8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54970 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495AbYB0J3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 04:29:54 -0500
In-Reply-To: <20080223000310.4630daa8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2008, Andrew Morton wrote:

> 
> (cc netdev)
> 
> On Wed, 20 Feb 2008 20:04:39 -0800 (PST) Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com> wrote:
> 
> > This is what I got with dmesg :
> > 
> > [  266.978695] WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
> > [  266.978701] Pid: 0, comm: swapper Not tainted 2.6.24.2-my001 #1
> > [  266.978703] 
> > [  266.978704] Call Trace:
> > [  266.978706]  <IRQ>  [<ffffffff80426981>] tcp_ack+0x16d8/0x197f
> > [  266.978721]  [<ffffffff8022e72f>] __wake_up+0x38/0x4e
> > [  266.978727]  [<ffffffff804295ef>] tcp_rcv_established+0xe2/0x8cb
> > [  266.978732]  [<ffffffff8042f56f>] tcp_v4_do_rcv+0x30/0x39c
> > [  266.978738]  [<ffffffff80431d29>] tcp_v4_rcv+0x99b/0xa06
> > [  266.978743]  [<ffffffff803f2c95>] __netdev_alloc_skb+0x29/0x43
> > [  266.978749]  [<ffffffff80416d21>] ip_local_deliver_finish+0x152/0x212
> > [  266.978753]  [<ffffffff80416bac>] ip_rcv_finish+0x2f8/0x31b
> > [  266.978758]  [<ffffffff803f6c42>] netif_receive_skb+0x3ae/0x3d1
> > [  266.978763]  [<ffffffff8037398f>] rtl8169_rx_interrupt+0x45f/0x53e
> > [  266.978768]  [<ffffffff8037405b>] rtl8169_poll+0x36/0x16a
> > [  266.978773]  [<ffffffff803f8ca7>] net_rx_action+0xb7/0x1f3
> > [  266.978778]  [<ffffffff8023a3a5>] __do_softirq+0x65/0xce
> > [  266.978782]  [<ffffffff8020b0d2>] default_idle+0x0/0x3d
> > [  266.978786]  [<ffffffff8020d09c>] call_softirq+0x1c/0x28
> > [  266.978789]  [<ffffffff8020e4f0>] do_softirq+0x2c/0x7d
> > [  266.978792]  [<ffffffff8023a2fb>] irq_exit+0x3f/0x84
> > [  266.978794]  [<ffffffff8020e729>] do_IRQ+0xb6/0xd5
> > [  266.978797]  [<ffffffff8020b0d2>] default_idle+0x0/0x3d
> > [  266.978800]  [<ffffffff8020c421>] ret_from_intr+0x0/0xa
> > [  266.978801]  <EOI>  [<ffffffff8020b0fb>] default_idle+0x29/0x3d
> > [  266.978809]  [<ffffffff8020b1a2>] cpu_idle+0x93/0xbb
> > [  266.978813]  [<ffffffff805cfa4b>] start_kernel+0x2bb/0x2c7
> > [  266.978818]  [<ffffffff805cf123>] _sinittext+0x123/0x12a
> > [  266.978821] 
> > 

Are you able to reproduce this in any way? I did in the past a debug patch 
that verifies TCP's write queue state by the hard way, ie., by bruteforce 
walking often enough to catch inconsistencies early enough to find out 
the root cause. I'll try to find that for you after I first go through 
the 2.6.24.2's code once again (but I'm pretty busy at this moment, so 
it might take a small while)...

> > This though didn't cause any user-visible problem.

Usually it's very insignificant to see them, unless you have them in very 
large quantities (it usually triggers for the same occurance in a number 
of places where that very same thing is being checked, thus having many 
of them in a row once is not what I mean here).

Were there Leak printouts as well a bit after that? If not, this is 
triggered with either non-SACK TCP or it is a genuine S+L bits bug.

-- 
 i.
