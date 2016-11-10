From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: mvpp2: don't bring up on MAC address set
Date: Thu, 10 Nov 2016 11:57:18 -0500 (EST)
Message-ID: <20161110.115718.1744727306693534849.davem@davemloft.net>
References: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mw@semihalf.com, netdev@vger.kernel.org,
        thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934274AbcKJQ5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 11:57:22 -0500
In-Reply-To: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Wed,  9 Nov 2016 14:56:33 +0200

> Current .ndo_set_mac_address implementation brings up the interface when revert
> to original address after failure succeeds. Fix this.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
> Untested; I don't have the hardware.

The code which updates the parser should keep the existing
state if any part of the update fails.

This means it must attempt all memory allocations and whatever other
resource acquisition is necessary, and only after all of those
operations succeed and no more error cases are possible should it
update the tables and release the old entry.

In other worse, this whole mechanism must move to a proper "prepare
--> commit" model of making changes.
