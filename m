From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] pktgen: make sure that pktgen_thread_worker has
 been executed
Date: Tue, 20 May 2008 15:12:57 -0700 (PDT)
Message-ID: <20080520.151257.87901660.davem@davemloft.net>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
	<1211277589-8565-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	robert.olsson@its.uu.se, greearb@candelatech.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763773AbYETWNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 18:13:02 -0400
In-Reply-To: <1211277589-8565-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 20 May 2008 13:59:47 +0400

> The following courruption can happen during pktgen stop:
> list_del corruption. prev->next should be ffff81007e8a5e70, but was 6b6b6b6b6b6b6b6b
> kernel BUG at lib/list_debug.c:67!
>       :pktgen:pktgen_thread_worker+0x374/0x10b0
>       ? autoremove_wake_function+0x0/0x40
>       ? _spin_unlock_irqrestore+0x42/0x80
>       ? :pktgen:pktgen_thread_worker+0x0/0x10b0
>       kthread+0x4d/0x80
>       child_rip+0xa/0x12
>       ? restore_args+0x0/0x30
>       ? kthread+0x0/0x80
>       ? child_rip+0x0/0x12
> RIP  list_del+0x48/0x70
> 
> The problem is that pktgen_thread_worker can not be executed if kthread_stop
> has been called too early. Insert a completion on the normal initialization
> path to make sure that pktgen_thread_worker will gain the control for sure.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Robert Olsson <robert.olsson@its.uu.se>
> Cc: Ben Greear <greearb@candelatech.com>
> Acked-by: Alexey Dobriyan <adobriyan@openvz.org>

Patch applied, thanks a lot Denis!
