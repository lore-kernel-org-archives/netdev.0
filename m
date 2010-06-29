From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH -next] sfc: set/clear NETIF_F_RXHASH bit directly
Date: Tue, 29 Jun 2010 15:43:29 +0100
Message-ID: <1277822609.2112.22.camel@achroite.uk.solarflarecom.com>
References: <20100629163520.642590bf@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50078 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756206Ab0F2Onc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 10:43:32 -0400
In-Reply-To: <20100629163520.642590bf@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-29 at 16:35 +0200, Stanislaw Gruszka wrote:
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
[...]

I don't think this is a positive change.

Please change ethtool_op_set_flags; then in efx_ethtool_set_flags() you
can do:

-	if (data & ~supported)
- 		return -EOPNOTSUPP;
- 
-	return ethtool_op_set_flags(net_dev, data);
+	return ethtool_op_set_flags(net_dev, data, supported);

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

