From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of_mdio: merge branch tails in
 of_phy_register_fixed_link()
Date: Sun, 13 Aug 2017 20:09:08 -0700 (PDT)
Message-ID: <20170813.200908.1426365653542179792.davem@davemloft.net>
References: <20170812210321.520045884@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, robh+dt@kernel.org,
        frowand.list@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750867AbdHNDJJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 23:09:09 -0400
In-Reply-To: <20170812210321.520045884@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 13 Aug 2017 00:03:06 +0300

> Looks  like gcc isn't always able to figure  out that 3 *if* branches in
> of_phy_register_fixed_link() calling fixed_phy_register() at their ends
> are similar enough and thus can be merged. The "manual" merge saves 40
> bytes of the object code (AArch64 gcc 4.8.5), and still saves 12 bytes
> even  if gcc was able to merge the branch tails (ARM gcc 4.8.5)...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, but if two instances of the "same" compiler just with
different targets changes the optimization, it could be because of a
tradeoff which is specific to parameters expressed in that target's
backend.

So in the future we should probably back away from trying to "help"
the compiler in this way.
