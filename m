From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: cpsw: add support for fixed-links.
Date: Mon, 09 Nov 2015 22:47:39 -0500 (EST)
Message-ID: <20151109.224739.975721323362436615.davem@davemloft.net>
References: <1447097054-4658-1-git-send-email-dtrautmann@ibhsoftec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, balbi@ti.com
To: dtrautmann@ibhsoftec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbKJDrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 22:47:42 -0500
In-Reply-To: <1447097054-4658-1-git-send-email-dtrautmann@ibhsoftec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Trautmann <dtrautmann@ibhsoftec.com>
Date: Mon, 9 Nov 2015 20:24:14 +0100

> @@ -2039,19 +2039,35 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
>  		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
>  		parp = of_get_property(slave_node, "phy_id", &lenp);
>  		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
> -			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);

I know this has nothing to do with your patch, but that length check
is completely bogus.

It should be "sizeof(__be32) * 2" not "sizeof(void *) * 2".
