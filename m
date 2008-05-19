From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Tue, 20 May 2008 00:45:43 +0200
Message-ID: <18482.791.580570.408048@robur.slu.se>
References: <20080519222145.GA4828@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, devzero@web.de, akpm@osdl.org,
	kaber@trash.net, den@openvz.org, adobriyan@parallels.com,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:53061 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754993AbYESXfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 19:35:21 -0400
In-Reply-To: <20080519222145.GA4828@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Alexey Dobriyan writes:
 > > list_del corruption. prev->next should be ffff81007e8a5e70, but was 6b6b6b6b6b6b6b6b
 > > kernel BUG at lib/list_debug.c:67!
 > >	:pktgen:pktgen_thread_worker+0x374/0x10b0
 > >	? autoremove_wake_function+0x0/0x40
 > >	? _spin_unlock_irqrestore+0x42/0x80
 > >	? :pktgen:pktgen_thread_worker+0x0/0x10b0
 > >	kthread+0x4d/0x80
 > >	child_rip+0xa/0x12
 > >	? restore_args+0x0/0x30
 > >	? kthread+0x0/0x80
 > >	? child_rip+0x0/0x12
 > > RIP  list_del+0x48/0x70
 > 
 > OK, trivial debugging and we know that worker thread function
 > (pktgen_thread_worker) never ran between kthread creation and rmmod.
 > 
 > Consequently, addition to "pktgen_threads" list happened, list_del of
 > thread 0 never happened, list_del of thread 1 barfs.

 Yes a schedule_timeout_interruptible(1) first in pg_cleanup seems to "cure" 
 insmod/rmmod race. You can even put the delay between the two proc removal 
 calls. But it seems we need a better way to sync so both start and stop 
 happen for all threads in pktgen_thread_worker before we remove the last proc 
 entries. And I see this with just one "controlling" process. 

 Cheers.
					--ro
