From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/5] qlcnic: Use correct netif api to enable tx
 queues.
Date: Tue, 10 Dec 2013 17:49:07 -0500 (EST)
Message-ID: <20131210.174907.841340337177313599.davem@davemloft.net>
References: <cover.1386648865.git.himanshu.madhani@qlogic.com>
	<a124e077076f2a1d1107200e629945108bd467bd.1386648865.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab3LJWtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:49:08 -0500
In-Reply-To: <a124e077076f2a1d1107200e629945108bd467bd.1386648865.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Tue, 10 Dec 2013 12:33:01 -0500

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> o commit id 012ec81223aa45d2b80aeafb77392fd1a19c7b10
>   ("qlcnic: Multi Tx queue support for 82xx Series adapter.")
>   enabled multiple tx queue API's for qlcnic driver.
>   During link change event, driver will stop/start Tx queues
>   which manages Link up event is received after Tx context is created
>   driver needs to call netif_tx_wake_all_queues()
> 
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

This is a symptom of the fact that this driver does not manage it's
queues correctly.

When the carrier is marked off, the core networking will not queue
packets to the device.

You should never manage queue state manually in response to link
state changes, netif_carrir_{on,off}() takes care of everything.
