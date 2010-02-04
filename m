From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] ixgbe: only process one
 ixgbe_watchdog_task at a time.
Date: Wed, 03 Feb 2010 19:47:07 -0800 (PST)
Message-ID: <20100203.194707.57344587.davem@davemloft.net>
References: <20100204002331.15847.40084.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756169Ab0BDDqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:46:54 -0500
In-Reply-To: <20100204002331.15847.40084.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 16:23:32 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Processing multiple ixgbe_watchdog_task calls may cause
> the link_up variable and IXGBE_FLAG_NEED_LINK_UPDATE flag
> to be set incorrectly.  In the worse case this is causing
> the netif_carrier_off to be called inappropriately which
> results in an interface that can't be brought up.
> 
> Although schedule_work() will only schedule the task if
> it is not already on the work queue the WORK_STRUCT_PENDING
> bits are cleared just before calling the work function.
> This allows WORK_STRUCT_PENDING to be cleared, the work
> function to start and meanwhile schedule another task.
> 
> This patch adds a mutex to the watchdog task. This bug is
> actualized by changing DCB settings or doing extended
> cable pull or reset tests.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
