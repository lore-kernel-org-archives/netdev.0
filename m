From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 19:28:20 +0200
Message-ID: <4AA542B4.4090206@trash.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>	<4AA14377.9020200@trash.net> <20090907.015039.154939751.davem@davemloft.net> <4AA503E4.2060504@gmail.com> <4AA50ACF.9010400@trash.net> <4AA5175F.6030600@trash.net> <4AA54128.2050607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38660 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbZIGR20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 13:28:26 -0400
In-Reply-To: <4AA54128.2050607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
>> I figured out the bug, which is likely responsible for both
>> problems. When grafting a mq class and creating a rate estimator,
>> the new qdisc is not attached to the device queue yet and also
>> doesn't have TC_H_ROOT as parent, so qdisc_create() selects
>> qdisc_root_sleeping_lock() for the estimator, which belongs to
>> the qdisc that is getting replaced.
>>
>> This is a patch I used for testing, but I'll come up with
>> something more elegant (I hope) as a final fix :)
> 
> Yes, this was the problem, and your patch fixed it.

Thanks for testing.

> Now adding CONFIG_SLUB_DEBUG_ON=y for next tries :)
> 
> Sep  7 16:37:55 erd kernel: [  217.056813] =============================================================================
> Sep  7 16:37:55 erd kernel: [  217.056865] BUG kmalloc-256: Poison overwritten
> Sep  7 16:37:55 erd kernel: [  217.056910] -----------------------------------------------------------------------------
> Sep  7 16:37:55 erd kernel: [  217.056911]
> Sep  7 16:37:55 erd kernel: [  217.056990] INFO: 0xf6e622bc-0xf6e622bd. First byte 0x76 instead of 0x6b
> Sep  7 16:37:55 erd kernel: [  217.057049] INFO: Allocated in qdisc_alloc+0x1b/0x80 age=154593 cpu=2 pid=5165
> Sep  7 16:37:55 erd kernel: [  217.057094] INFO: Freed in qdisc_destroy+0x88/0xa0 age=139186 cpu=4 pid=5173
> Sep  7 16:37:55 erd kernel: [  217.057139] INFO: Slab 0xc16ddc40 objects=26 used=6 fp=0xf6e62260 flags=0x28040c3
> Sep  7 16:37:55 erd kernel: [  217.057184] INFO: Object 0xf6e62260 @offset=608 fp=0xf6e62850
> Sep  7 16:37:55 erd kernel: [  217.057184]

I'm unable to reproduce this. Could you send me the commands you
used that lead to this?

