From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: keep carrier off after registering
 netdev
Date: Wed, 17 May 2017 12:01:58 -0400 (EDT)
Message-ID: <20170517.120158.815958672031647352.davem@davemloft.net>
References: <1494950185-15356-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, surendra@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753672AbdEQQCF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 12:02:05 -0400
In-Reply-To: <1494950185-15356-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 16 May 2017 21:26:25 +0530

> From: Surendra Mobiya <surendra@chelsio.com>
> 
> Mark carrier off after registering netdev to ensure that vlan device
> picks up the correct state of the carrier
> 
> Signed-off-by: Surendra Mobiya <surendra@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

This doesn't work.

At the very moment you perform the register netdev, it can be
openned, stacked onto other devices (like VLANs) etc. before
your line doing the carrier off occurs.

So once you do the netdev register, all the state must be
completely settled beforehand.
