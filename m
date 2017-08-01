From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] gue: fix remcsum when GRO on and
 CHECKSUM_PARTIAL boundary is outer UDP
Date: Tue, 01 Aug 2017 16:09:34 -0700 (PDT)
Message-ID: <20170801.160934.708158318948829431.davem@davemloft.net>
References: <20170731160539.6013-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: den@klaipeden.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdHAXJe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 19:09:34 -0400
In-Reply-To: <20170731160539.6013-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koichiro Den <den@klaipeden.com>
Date: Tue,  1 Aug 2017 01:05:39 +0900

> In the case that GRO is turned on and the original received packet is
> CHECKSUM_PARTIAL, if the outer UDP header is exactly at the last
> csum-unnecessary point, which for instance could occur if the packet
> comes from another Linux guest on the same Linux host, we have to do
> either remcsum_adjust or set up CHECKSUM_PARTIAL again with its
> csum_start properly reset considering RCO.
> 
> However, since b7fe10e5ebac ("gro: Fix remcsum offload to deal with frags
> in GRO") that barrier in such case could be skipped if GRO turned on,
> hence we pass over it and the inner L4 validation mistakenly reckons
> it as a bad csum.
> 
> This patch makes remcsum_offload being reset at the same time of GRO
> remcsum cleanup, so as to make it work in such case as before.
> 
> Fixes: b7fe10e5ebac ("gro: Fix remcsum offload to deal with frags in GRO")
> Signed-off-by: Koichiro Den <den@klaipeden.com>

Applied.
