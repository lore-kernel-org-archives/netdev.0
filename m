From: Alexey Dobriyan <adobriyan@parallels.com>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 20:03:20 +0400
Message-ID: <200805192003.21465.adobriyan@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, kaber@trash.net, den@openvz.org,
	netdev@vger.kernel.org, devzero@web.de
To: bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31840 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756644AbYESQEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 12:04:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> remove_proc_entry: removing non-empty directory 'net/pktgen', leaking at least 'kpktgend_1'

reproduced, and BTW, proc stuff is least of worries. It can also oops via

list_del corruption. prev->next should be ffff81007e8a5e70, but was 6b6b6b6b6b6b6b6b
kernel BUG at lib/list_debug.c:67!
 :pktgen:pktgen_thread_worker+0x374/0x10b0
 ? autoremove_wake_function+0x0/0x40
 ? _spin_unlock_irqrestore+0x42/0x80
 ? :pktgen:pktgen_thread_worker+0x0/0x10b0
 kthread+0x4d/0x80
 child_rip+0xa/0x12
 ? restore_args+0x0/0x30
 ? kthread+0x0/0x80
 ? child_rip+0x0/0x12
RIP  list_del+0x48/0x70
