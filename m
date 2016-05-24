From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/qlge: Avoids recursive EEH error
Date: Tue, 24 May 2016 14:48:18 -0700 (PDT)
Message-ID: <20160524.144818.1618490116569101413.davem@davemloft.net>
References: <1463968708-28368-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harish.patil@qlogic.com,
	sudarsana.kalluru@qlogic.com, shriyakul@in.ibm.com
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbcEXVsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 17:48:19 -0400
In-Reply-To: <1463968708-28368-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Mon, 23 May 2016 11:58:28 +1000

> One timer, whose handler keeps reading on MMIO register for EEH
> core to detect error in time, is started when the PCI device driver
> is loaded. MMIO register can't be accessed during PE reset in EEH
> recovery. Otherwise, the unexpected recursive error is triggered.
> The timer isn't closed that time if the interface isn't brought
> up. So the unexpected recursive error is seen during EEH recovery
> when the interface is down.
> 
> This avoids the unexpected recursive EEH error by closing the timer
> in qlge_io_error_detected() before EEH PE reset unconditionally. The
> timer is started unconditionally after EEH PE reset in qlge_io_resume().
> Also, the timer should be closed unconditionally when the device is
> removed from the system permanently in qlge_io_error_detected().
> 
> Reported-by: Shriya R. Kulkarni <shriyakul@in.ibm.com>
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

Applied, thanks.
