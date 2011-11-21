From: David Miller <davem@davemloft.net>
Subject: Re: [v2,7/7] gianfar: add support for wake-on-packet
Date: Mon, 21 Nov 2011 14:53:09 -0500 (EST)
Message-ID: <20111121.145309.1585525390358079784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chenhui.zhao@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab1KUTxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 14:53:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The ->gfar_set_wol() code doesn't validate that the requested settings
do not try to set bits outside of priv->wol_supported.

Just remove the check against "!priv->wol_supported" and replace it
with something like "!(wol->wolopts & ~priv->wol_supported)"
