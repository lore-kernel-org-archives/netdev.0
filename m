From: Vitaliy Gusev <vgusev@openvz.org>
Subject: Re: [PATCH 3/4] forcedeth: napi schedule lock fix
Date: Tue, 27 Jan 2009 19:28:16 +0300
Message-ID: <200901271928.16783.vgusev@openvz.org>
References: <4967BBB5.9080803@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16218 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156AbZA0Qh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 11:37:57 -0500
In-Reply-To: <4967BBB5.9080803@nvidia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 January 2009 00:03:49 Ayaz Abdulla wrote:
> This patch fixes a potential race condition between scheduling napi and 
> completing napi poll. The call to netif_rx_schedule should be under 
> protection of the lock (as is the completion), otherwise, interrupts 
> could be masked off.

Can you explain how this issue or race can occur (interrupts can be masked off) ?

netif_rx_schedule() merely mark soft irq as waked on current CPU. So dev->poll
will not be called until irq_exit() or local_bh_enable. As nv_nic_irq() is run
under interrupt context, so napi poll will be called only during irq_exit.


> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 



-- 
Thank,
Vitaliy Gusev
