From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Don't flush multicast MACs
Date: Wed, 24 Aug 2016 09:45:33 -0700 (PDT)
Message-ID: <20160824.094533.509802658254921566.davem@davemloft.net>
References: <1472034439-18810-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33699 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753695AbcHXQqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:46:09 -0400
In-Reply-To: <1472034439-18810-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 24 Aug 2016 13:27:19 +0300

> When ndo_set_rx_mode() is called for bnx2x, as part of process of
> configuring the new MAC address filters [both unicast & multicast]
> driver begins by flushing the existing configuration and then iterating
> over the network device's list of addresses and configures those instead.
> 
> This has the side-effect of creating a short gap where traffic wouldn't
> be properly classified, as no filters are configured in HW.
> While for unicasts this is rather insignificant [as unicast MACs don't
> frequently change while interface is actually running],
> for multicast traffic it does pose an issue as there are multicast-based
> networks where new multicast groups would constantly be removed and
> added.
> 
> This patch tries to remedy this [at least for the newer adapters] -
> Instead of flushing & reconfiguring all existing multicast filters,
> the driver would instead create the approximate hash match that would
> result from the required filters. It would then compare it against the
> currently configured approximate hash match, and only add and remove the
> delta between those.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
