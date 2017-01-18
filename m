From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethtool: avoid allocation failure for dump_regs
Date: Wed, 18 Jan 2017 11:45:05 -0500 (EST)
Message-ID: <20170118.114505.1855687422610394730.davem@davemloft.net>
References: <1484746445-97920-1-git-send-email-darcari@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: darcari@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752065AbdARQpH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 11:45:07 -0500
In-Reply-To: <1484746445-97920-1-git-send-email-darcari@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Arcari <darcari@redhat.com>
Date: Wed, 18 Jan 2017 08:34:05 -0500

> If the user executes 'ethtool -d' for an interface and the associated
> get_regs_len() function returns 0, the user will see a call trace from
> the vmalloc() call in ethtool_get_regs().  This patch modifies
> ethtool_get_regs() to avoid the call to vmalloc when the size is zero.
> 
> Signed-off-by: David Arcari <darcari@redhat.com>

I think when the driver indicates this, it is equivalent to saying that
the operation isn't supported.

Also, this guards us against ->get_regs() methods that don't handle
zero length requests properly.  I see many which are going to do
really terrible things in that situation.

Therefore, if get_regs_len() returns zero, treat it the safe as if the
ethtool operations were NULL.

Thanks.
