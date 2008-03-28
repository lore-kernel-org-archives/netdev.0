From: Dave Jones <davej@codemonkey.org.uk>
Subject: Another 2.6.25rc7 lockdep trace
Date: Thu, 27 Mar 2008 21:54:16 -0400
Message-ID: <20080328015416.GB4695@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:53365 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbYC1ByX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 21:54:23 -0400
Received: from c-66-30-206-50.hsd1.ma.comcast.net ([66.30.206.50] helo=gelk.kernelslacker.org)
	by testure.choralone.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1Jf3jO-0004y7-Kp
	for netdev@vger.kernel.org; Fri, 28 Mar 2008 01:50:10 +0000
Received: from davej by gelk.kernelslacker.org with local (Exim 4.68)
	(envelope-from <davej@gelk.kernelslacker.org>)
	id 1Jf3nM-00053B-2O
	for netdev@vger.kernel.org; Thu, 27 Mar 2008 21:54:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems different to the one I just posted.  This one popped up
after a barrage of random packets..

	Dave

 =================================
 [ INFO: inconsistent lock state ]
 2.6.25-0.161.rc7.fc9.i686 #1
 ---------------------------------
 inconsistent {in-softirq-W} -> {softirq-on-R} usage.
 modprobe/7285 [HC0[0]:SC0[0]:HE1:SE1] takes:
  (&f->lock){-+-?}, at: [inet_frag_evictor+60/175] inet_frag_evictor+0x3c/0xaf
 {in-softirq-W} state was registered at:
   [__lock_acquire+1216/3089] __lock_acquire+0x4c0/0xc11
   [lock_acquire+106/144] lock_acquire+0x6a/0x90
   [_write_lock+28/73] _write_lock+0x1c/0x49
   [inet_frag_find+216/405] inet_frag_find+0xd8/0x195
   [ip_defrag+174/2168] ip_defrag+0xae/0x878
   [<d0ca53e2>] ipv4_conntrack_defrag+0x4c/0x72 [nf_conntrack_ipv4]
   [nf_iterate+47/100] nf_iterate+0x2f/0x64
   [nf_hook_slow+85/193] nf_hook_slow+0x55/0xc1
   [ip_rcv+494/551] ip_rcv+0x1ee/0x227
   [netif_receive_skb+901/968] netif_receive_skb+0x385/0x3c8
   [<d0d2488f>] e100_poll+0x165/0x2fb [e100]
   [net_rx_action+203/506] net_rx_action+0xcb/0x1fa
   [__do_softirq+132/266] __do_softirq+0x84/0x10a
   [do_softirq+121/218] do_softirq+0x79/0xda
   [<ffffffff>] 0xffffffff
 irq event stamp: 7247
 hardirqs last  enabled at (7247): [_spin_unlock_irqrestore+64/80] _spin_unlock_irqrestore+0x40/0x50
 hardirqs last disabled at (7246): [_spin_lock_irqsave+35/104] _spin_lock_irqsave+0x23/0x68
 softirqs last  enabled at (7244): [<d0e3a794>] nf_ct_iterate_cleanup+0xdc/0xfb [nf_conntrack]
 softirqs last disabled at (7242): [_spin_lock_bh+12/78] _spin_lock_bh+0xc/0x4e
 
 other info that might help us debug this:
 no locks held by modprobe/7285.
 
 stack backtrace:
 Pid: 7285, comm: modprobe Not tainted 2.6.25-0.161.rc7.fc9.i686 #1
  [print_usage_bug+266/279] print_usage_bug+0x10a/0x117
  [mark_lock+822/1009] mark_lock+0x336/0x3f1
  [__lock_acquire+1349/3089] __lock_acquire+0x545/0xc11
  [_spin_unlock_irq+34/47] ? _spin_unlock_irq+0x22/0x2f
  [lock_acquire+106/144] lock_acquire+0x6a/0x90
  [inet_frag_evictor+60/175] ? inet_frag_evictor+0x3c/0xaf
  [_read_lock+28/73] _read_lock+0x1c/0x49
  [inet_frag_evictor+60/175] ? inet_frag_evictor+0x3c/0xaf
  [inet_frag_evictor+60/175] inet_frag_evictor+0x3c/0xaf
  [<d0e299f2>] nf_ct_frag6_cleanup+0x26/0x28 [nf_conntrack_ipv6]
  [<d0e2a3f4>] nf_conntrack_l3proto_ipv6_fini+0x44/0x46 [nf_conntrack_ipv6]
  [sys_delete_module+418/475] sys_delete_module+0x1a2/0x1db
  [audit_syscall_entry+249/291] ? audit_syscall_entry+0xf9/0x123
  [syscall_call+7/11] syscall_call+0x7/0xb
  =======================


-- 
http://www.codemonkey.org.uk
