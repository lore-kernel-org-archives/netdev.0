From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: cpsw: fix wrong regs access in
 cpsw_ndo_open
Date: Thu, 21 Apr 2016 14:31:09 -0400 (EDT)
Message-ID: <20160421.143109.221343460795174482.davem@davemloft.net>
References: <1461089389-17508-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, nsekhar@ti.com,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbcDUSbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:31:11 -0400
In-Reply-To: <1461089389-17508-1-git-send-email-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Tue, 19 Apr 2016 21:09:49 +0300

> The cpsw_ndo_open() could try to access CPSW registers before
> calling pm_runtime_get_sync(). This will trigger L3 error:
> 
>  WARNING: CPU: 0 PID: 21 at drivers/bus/omap_l3_noc.c:147 l3_interrupt_handler+0x220/0x34c()
>  44000000.ocp:L3 Custom Error: MASTER M2 (64-bit) TARGET L4_FAST (Idle): Data Access in Supervisor mode during Functional access
> 
> and CPSW will stop functioning.
> 
> Hence, fix it by moving pm_runtime_get_sync() before the first access
> to CPSW registers in cpsw_ndo_open().
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied, thanks.
