From: Patrick McHardy <kaber@trash.net>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 09:12:20 +0100
Message-ID: <49081AE4.9040301@trash.net>
References: <20081029071549.GA4861@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58930 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbYJ2IMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 04:12:24 -0400
In-Reply-To: <20081029071549.GA4861@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 29-10-2008 01:08, Jay Cliburn wrote:
>> I'm pretty fuzzy on the mechanics of warn_on_slowpath, so I'd like to
>> ask for help from more experienced netdev developers.
>>
>> An atl1 user reports the following warning when receiving a VLAN tagged
>> packet.
>>
>> [   27.779463] ------------[ cut here ]------------
>> [   27.779509] WARNING: at kernel/softirq.c:136 local_bh_enable+0x37/0x81()
> ...
>> [   27.782520]  [<c0264755>] netif_nit_deliver+0x5b/0x75
>> [   27.782590]  [<c02bba83>] __vlan_hwaccel_rx+0x79/0x162
>> [   27.782664]  [<f8851c1d>] atl1_intr+0x9a9/0xa7c [atl1]
>> [   27.782738]  [<c0155b17>] handle_IRQ_event+0x23/0x51
>> [   27.782808]  [<c015692e>] handle_edge_irq+0xc2/0x102
>> [   27.782878]  [<c0105fd5>] do_IRQ+0x4d/0x64
>> [   27.782947]  [<c010434f>] common_interrupt+0x23/0x28
>> [   27.783017]  [<c0108df6>] mwait_idle+0x2f/0x3b
>> [   27.783085]  [<c0102a75>] cpu_idle+0xde/0x101
>> [   27.783154]  =======================
>> [   27.783195] ---[ end trace 744634f3da93b46a ]---
>>
>> I've flailed around trying to find the bug, but haven't been
>> successful -- primarily because I don't understand the
>> warn_on_slowpath stuff well enough to know what to look for. Can someone
>> please take a quick look at drivers/net/atlx/atl1.c around line 2017
>> and see if there's an obvious error?  I'd really appreciate it.
> 
> It looks to me like vlan_hwaccel_rx() is to blame: I doubt we can do
> netif_nit_deliver() in hard irq context. (Patrick Cc-ed.)

Crap, I didn't think of that, all drivers I tested with support
NAPI. I can't think of a clean way to fix it right now, but I'll
look into it.
