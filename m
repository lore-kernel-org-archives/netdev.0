From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] inet: ip defrag bug fixes
Date: Sun, 26 Jul 2015 21:00:36 -0700 (PDT)
Message-ID: <20150726.210036.2175646567443197922.davem@davemloft.net>
References: <1437645940-7895-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johan@transip.nl, fschreuder@transip.nl,
	nikolay@cumulusnetworks.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbbG0EAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 00:00:37 -0400
In-Reply-To: <1437645940-7895-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 23 Jul 2015 12:05:36 +0200

> Johan Schuijt and Frank Schreuder reported crash and softlockup after the
> inet workqueue eviction change:
> 
> general protection fault: 0000 [#1] SMP
> CPU: 0 PID: 4 Comm: kworker/0:0 Not tainted 3.18.18-transip-1.5 #1
> Workqueue: events inet_frag_worker
> task: ffff880224935130 ti: ffff880224938000 task.ti: ffff880224938000
> RIP: 0010:[<ffffffff8149288c>] [<ffffffff8149288c>] inet_evict_bucket+0xfc/0x160
> RSP: 0018:ffff88022493bd58  EFLAGS: 00010286
> RAX: ffff88021f4f3e80 RBX: dead000000100100 RCX: 000000000000006b
> RDX: 000000000000006c RSI: ffff88021f4f3e80 RDI: dead0000001000a8
> RBP: 0000000000000002 R08: ffff880222273900 R09: ffff880036e49200
> R10: ffff8800c6e86500 R11: ffff880036f45500 R12: ffffffff81a87100
> R13: ffff88022493bd70 R14: 0000000000000000 R15: ffff8800c9b26280
> [..]
> Call Trace:
>  [<ffffffff814929e0>] ? inet_frag_worker+0x60/0x210
>  [<ffffffff8107e3a2>] ? process_one_work+0x142/0x3b0
>  [<ffffffff8107eb94>] ? worker_thread+0x114/0x440
> [..]
> 
> A second issue results in softlockup since the evictor may restart the
> eviction loop for a (potentially) unlimited number of times while local
> softirqs are disabled.
> 
> Frank reports that test system remained stable for 14 hours of testing
> (before, crash occured within half an hour in their setup).

Looks great, series applied, thanks everyone.
