From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 2/4] cxgb3: fix workqueue flush issues
Date: Mon, 20 Apr 2009 02:08:19 -0700 (PDT)
Message-ID: <20090420.020819.234015726.davem@davemloft.net>
References: <20090417222117.8504.11164.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754803AbZDTJI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:08:27 -0400
In-Reply-To: <20090417222117.8504.11164.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Fri, 17 Apr 2009 15:21:17 -0700

> The fatal error task can be scheduled while processing an offload packet
> in NAPI context when the connection handle is bogus. this can race
> with the ports being brought down and the cxgb3 workqueue being flushed.
> Stop napi processing before flushing the work queue.
> 
> The ULP drivers (iSCSI, iWARP) might also schedule a task on keventd_wk 
> while releasing a connection handle (cxgb3_offload.c::cxgb3_queue_tid_release()).
> The driver however does not flush any work on keventd_wq while being unloaded. 
> This patch also fixes this.
> 
> Also call cancel_delayed_work_sync in place of the the deprecated
> cancel_rearming_delayed_workqueue.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
