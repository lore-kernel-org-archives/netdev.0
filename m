From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cnic: Fix rtnl deadlock
Date: Fri, 08 Apr 2011 13:03:12 -0700 (PDT)
Message-ID: <20110408.130312.71109273.davem@davemloft.net>
References: <1302284654-25864-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757833Ab1DHUDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 16:03:48 -0400
In-Reply-To: <1302284654-25864-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 8 Apr 2011 10:44:14 -0700

> When cnic_stop_hw() -> cnic_cm_stop_bnx2x_hw() is called under rtnl_lock()
> from NETDEV_DOWN event, it waits for cnic_delete_task() to complete.
> It will deadlock when cnic_delete_task() takes rtnl_lock() before
> calling cnic_ulp_stop_one().
> 
> We fix it by removing the rtnl_lock() in cnic_delete_task().
> cnic_ulp_stop_one() has mutex and atomic bit ops to prevent important
> operations from being done more than once, so it is not necessary to take
> rtnl_lock().
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
