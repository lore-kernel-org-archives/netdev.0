From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Don't call cxgb_vlan_mode until q locks are
 initialized
Date: Mon, 30 Apr 2012 22:09:39 -0400 (EDT)
Message-ID: <20120430.220939.1458086000301177724.davem@davemloft.net>
References: <1335806147-17310-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org, roland@purestorage.com
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab2EACJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 22:09:47 -0400
In-Reply-To: <1335806147-17310-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Mon, 30 Apr 2012 10:15:47 -0700

> From: Roland Dreier <roland@purestorage.com>
> 
> The driver calls cxgb_vlan_mode() from init_one().  This calls into
> synchronize_rx(), which locks all the q locks, but the q locks are not
> initialized until cxgb_up() -> setup_sge_qsets().  So move the call to
> cxgb_vlan_mode() into cxgb_up(), after the call to setup_sge_qsets().
> We also move the body of these functions up higher to avoid having to
> a forward declaration.
> 
> This was found because of the lockdep warning:
 ...
> Contrary to what lockdep says, the code is not fine: we are locking an
> uninitialized spinlock.
> 
> Signed-off-by: Roland Dreier <roland@purestorage.com>

Applied, thanks.
