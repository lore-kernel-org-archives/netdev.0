From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] drivers/atm/eni.c: ensure arguments to request_irq
 and free_irq are compatible
Date: Sun, 11 Mar 2012 15:42:19 -0700 (PDT)
Message-ID: <20120311.154219.270150852508281564.davem@davemloft.net>
References: <201203112058.q2BKwBCS024617@cmf.nrl.navy.mil>
	<alpine.DEB.2.02.1203112215250.1958@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab2CKWqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:46:31 -0400
In-Reply-To: <alpine.DEB.2.02.1203112215250.1958@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Sun, 11 Mar 2012 22:16:25 +0100 (CET)

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Convert calls to free_irq so that the second argument is the same as
> the
> last argument of the corresponding call to request_irq.  Without this
> property, free_irq does nothing.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, but this driver also has a larger problem, it doesn't
free the IRQ (nor do any other kind of chip shutdown and cleanups)
when the driver is unloaded.  The unload function is just one empty
function with a comment.
