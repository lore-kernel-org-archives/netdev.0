From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: Fix BlueFlame race
Date: Mon, 29 Jul 2013 00:55:27 -0700 (PDT)
Message-ID: <20130729.005527.2071951598362619468.davem@davemloft.net>
References: <1374769283-18580-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab3G2Hz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 03:55:28 -0400
In-Reply-To: <1374769283-18580-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 25 Jul 2013 19:21:23 +0300

> From: Eugenia Emantayev <eugenia@mellanox.com>
> 
> Fix a race between BlueFlame flow and stamping in post send flow.
> Example:
> 	SW: Build WQE 0 on the TX buffer, except the ownership bit
> 	SW: Set ownership for WQE 0 on the TX buffer
> 	SW: Ring doorbell for WQE 0
> 	SW: Build WQE 1 on the TX buffer, except the ownership bit
> 	SW: Set ownership for WQE 1 on the TX buffer
> 	HW: Read WQE 0 and then WQE 1, before doorbell was rung/BF was done for WQE 1
> 	HW: Produce CQEs for WQE 0 and WQE 1
> 	SW: Process the CQEs, and stamp WQE 0 and WQE 1 accordingly (on the TX buffer)
> 	SW: Copy WQE 1 from the TX buffer to the BF register - ALREADY STAMPED!
> 	HW: CQE error with index 0xFFFF  - the BF WQE's control segment is STAMPED,
> 		so the BF index is 0xFFFF. Error: Invalid Opcode.
> As a result QP enters the error state and no traffic can be sent.
> 
> Solution:
> When stamping - do not stamp last completed wqe.
> 
> 
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
