From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] altera_tse: Fixes in NAPI and interrupt
 handling paths
Date: Mon, 23 Feb 2015 18:08:15 -0500 (EST)
Message-ID: <20150223.180815.2270832900387656053.davem@davemloft.net>
References: <1424712629-24330-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org, vbridger@altera.com, setka@vsis.cz,
	rpisl@kky.zcu.cz
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424712629-24330-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Mon, 23 Feb 2015 11:30:29 -0600

> From: Vlastimil Setka <setka@vsis.cz>
> 
> Incorrect NAPI polling caused WARNING at net/core/dev.c net_rx_action.
> Some stability issues were also seen at high throughput and system
> load before this patch.
> 
> This patch contains several changes in altera_tse_main.c:
> 
> - tse_rx() is fixed to not process more than `limit` frames
> 
> - tse_poll() is refactored to match NAPI logic
>   - only received frames are counted for return value
>   - removed bogus condition `(rxcomplete >= budget || txcomplete > 0)`
>   - replace by: if (rxcomplete < budget) -> call __napi_complete and enable irq
> 
> - altera_isr()
>   - replace spin_lock_irqsave() by spin_lock() - we are in isr
>   - use spinlocks just over irq manipulation, not over __napi_schedule
>   - reset IRQ first, then disable and schedule napi
> 
> This is a cleaned up resubmission from Vlastimil's recent submission.
> 
> Signed-off-by: Vlastimil Setka <setka@vsis.cz>
> Signed-off-by: Roman Pisl <rpisl@kky.zcu.cz>
> Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>

This is also a bug fix, and therefore not appropriate to target at 'net-next'.

I've applied it to 'net' instead.
