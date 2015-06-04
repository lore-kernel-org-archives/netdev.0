From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Fix build failure introduced
 by the EQ pool changes
Date: Wed, 03 Jun 2015 19:36:15 -0700 (PDT)
Message-ID: <20150603.193615.834853895798751401.davem@davemloft.net>
References: <1433230188-29726-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpe@ellerman.id.au, amirv@mellanox.com,
	matanb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbbFDCgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:36:16 -0400
In-Reply-To: <1433230188-29726-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue,  2 Jun 2015 10:29:48 +0300

> When CONFIG_RFS_ACCEL or SMP aren't set, we fail to build, fix it.
> 
> Also, avoid build warning as of unused function on that setup.
> 
> Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, but this is really silly.

The whole reason there are backup non-SMP inline versions of
irq_set_affinity_hint() is so that drivers don't have to crap
up their drivers with ifdef'ery like this.

Just make all of this code unconditional and ignore the error,
there isn't anything you can really do if the error happens
anyways and this allows you to just silently use the non-SMP
variant which unconditionally returns -EINVAL.
