From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Tue, 20 May 2008 02:21:45 +0400
Message-ID: <20080519222145.GA4828@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devzero@web.de, akpm@osdl.org, kaber@trash.net, den@openvz.org,
	adobriyan@parallels.com, netdev@vger.kernel.org
To: bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:10241 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760231AbYESV0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 17:26:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so819095nfc.21
        for <netdev@vger.kernel.org>; Mon, 19 May 2008 14:26:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> list_del corruption. prev->next should be ffff81007e8a5e70, but was 6b6b6b6b6b6b6b6b
> kernel BUG at lib/list_debug.c:67!
>	:pktgen:pktgen_thread_worker+0x374/0x10b0
>	? autoremove_wake_function+0x0/0x40
>	? _spin_unlock_irqrestore+0x42/0x80
>	? :pktgen:pktgen_thread_worker+0x0/0x10b0
>	kthread+0x4d/0x80
>	child_rip+0xa/0x12
>	? restore_args+0x0/0x30
>	? kthread+0x0/0x80
>	? child_rip+0x0/0x12
> RIP  list_del+0x48/0x70

OK, trivial debugging and we know that worker thread function
(pktgen_thread_worker) never ran between kthread creation and rmmod.

Consequently, addition to "pktgen_threads" list happened, list_del of
thread 0 never happened, list_del of thread 1 barfs.

