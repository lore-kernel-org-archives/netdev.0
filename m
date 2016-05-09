From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: arc/emac: Move arc_emac_tx_clean() into
 arc_emac_tx() and disable tx interrut
Date: Sun, 08 May 2016 23:42:56 -0400 (EDT)
Message-ID: <20160508.234256.359620681931531068.davem@davemloft.net>
References: <1462537156-10489-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
	sy.w@outlook.com, al.kochet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wxt@rock-chips.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcEIDnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:43:01 -0400
In-Reply-To: <1462537156-10489-1-git-send-email-wxt@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Caesar Wang <wxt@rock-chips.com>
Date: Fri,  6 May 2016 20:19:16 +0800

> Doing tx_clean() inside poll() may scramble the tx ring buffer if
> tx() is running. This will cause tx to stop working, which can be
> reproduced by simultaneously downloading two large files at high speed.
> 
> Moving tx_clean() into tx() will prevent this. And tx interrupt is no
> longer needed now.

TX completion work is always recommended to be done in the ->poll()
handler.

Fix the race or whatever bug there is rather than working around it,
and regressing the driver, by handling TX completion in the interrupt
handler.

Thanks.
