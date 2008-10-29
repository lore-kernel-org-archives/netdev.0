From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 07:15:50 +0000
Message-ID: <20081029071549.GA4861@ff.dom.local>
References: <20081028190846.2cc3bd3f@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:4967 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbYJ2HP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 03:15:58 -0400
Received: by ug-out-1314.google.com with SMTP id 39so508640ugf.37
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 00:15:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081028190846.2cc3bd3f@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-10-2008 01:08, Jay Cliburn wrote:
> I'm pretty fuzzy on the mechanics of warn_on_slowpath, so I'd like to
> ask for help from more experienced netdev developers.
> 
> An atl1 user reports the following warning when receiving a VLAN tagged
> packet.
> 
> [   27.779463] ------------[ cut here ]------------
> [   27.779509] WARNING: at kernel/softirq.c:136 local_bh_enable+0x37/0x81()
...
> [   27.782520]  [<c0264755>] netif_nit_deliver+0x5b/0x75
> [   27.782590]  [<c02bba83>] __vlan_hwaccel_rx+0x79/0x162
> [   27.782664]  [<f8851c1d>] atl1_intr+0x9a9/0xa7c [atl1]
> [   27.782738]  [<c0155b17>] handle_IRQ_event+0x23/0x51
> [   27.782808]  [<c015692e>] handle_edge_irq+0xc2/0x102
> [   27.782878]  [<c0105fd5>] do_IRQ+0x4d/0x64
> [   27.782947]  [<c010434f>] common_interrupt+0x23/0x28
> [   27.783017]  [<c0108df6>] mwait_idle+0x2f/0x3b
> [   27.783085]  [<c0102a75>] cpu_idle+0xde/0x101
> [   27.783154]  =======================
> [   27.783195] ---[ end trace 744634f3da93b46a ]---
> 
> I've flailed around trying to find the bug, but haven't been
> successful -- primarily because I don't understand the
> warn_on_slowpath stuff well enough to know what to look for. Can someone
> please take a quick look at drivers/net/atlx/atl1.c around line 2017
> and see if there's an obvious error?  I'd really appreciate it.

It looks to me like vlan_hwaccel_rx() is to blame: I doubt we can do
netif_nit_deliver() in hard irq context. (Patrick Cc-ed.)

Jarek P.
