From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Mon, 20 Jun 2011 18:33:16 +0200
Message-ID: <20110620163316.GC994@wantstofly.org>
References: <cover.1308555865.git.richard.cochran@omicron.at>
 <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, stable@kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:57622 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab1FTQdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 12:33:18 -0400
Content-Disposition: inline
In-Reply-To: <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2011 at 09:48:07AM +0200, Richard Cochran wrote:

> Because the socket buffer is freed in the completion interrupt, it
> is not safe to access it after submitting it to the hardware.

Maybe I'm missing something here, but mv643xx_eth TX reclaim is done
from NAPI poll, under __netif_tx_lock(), while mv643xx_eth_xmit() also
runs under __netif_tx_lock().
