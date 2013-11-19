From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: 3.12.0+ INFO: inconsistent lock state
Date: Tue, 19 Nov 2013 06:30:16 +0000 (UTC)
Message-ID: <slrnl8m1c3.8pg.xiyou.wangcong@linux-6brj.site>
References: <23618767.907181384423756972.JavaMail.weblogic@epv6ml03>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:33805 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762Ab3KSGaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 01:30:39 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ViepY-0008BD-Bw
	for netdev@vger.kernel.org; Tue, 19 Nov 2013 07:30:36 +0100
Received: from c-24-5-209-215.hsd1.ca.comcast.net ([24.5.209.215])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 07:30:36 +0100
Received: from xiyou.wangcong by c-24-5-209-215.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 07:30:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Nov 2013 at 10:09 GMT, Jongman Heo <jongman.heo@samsung.com> wrote:
>
> Hi,
>
> With current linus git (HEAD 4fbf888accb3), I got following kernel message.
> Maybe related to commit 827da44c6141 ("net: Explicitly initialize u64_stats_sync structures for lockdep") ?
>
> [   43.886589] =================================
> [   43.886590] [ INFO: inconsistent lock state ]
> [   43.886593] 3.12.0+ #34 Not tainted
> [   43.886594] ---------------------------------
> [   43.886595] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> [   43.886597] swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [   43.886599]  (&af_inet_stats->syncp.seq){+.?...}, at: [<c09dd983>] __netif_receive_skb_core+0x513/0x6a0
> [   43.886609] {SOFTIRQ-ON-W} state was registered at:
> [   43.886610]   [<c04a08b7>] __lock_acquire+0x467/0x1830
> [   43.886614]   [<c04a1d18>] lock_acquire+0x98/0x120
> [   43.886617]   [<c0a3718a>] ip4_datagram_connect+0x2ea/0x310
> [   43.886621]   [<c0a44cfa>] inet_dgram_connect+0x2a/0x80
> [   43.886624]   [<c09c8481>] SYSC_connect+0xb1/0xd0
> [   43.886627]   [<c09c9366>] SYSC_socketcall+0x226/0x980
> [   43.886629]   [<c09c9b93>] SyS_socketcall+0x13/0x20
> [   43.886631]   [<c0b03bcd>] sysenter_do_call+0x12/0x38

This is fixed by:
http://marc.info/?l=linux-netdev&m=138446510213411&w=2
