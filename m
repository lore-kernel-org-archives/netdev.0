From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net] openvswitch: Fix for force/commit action
 failures
Date: Sat, 15 Jul 2017 14:40:40 -0700 (PDT)
Message-ID: <20170715.144040.2208563191392538027.davem@davemloft.net>
References: <1500061369-27918-1-git-send-email-gvrose8192@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dev@openvswitch.org,
        joe@ovn.org
To: gvrose8192@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdGOVkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2017 17:40:41 -0400
In-Reply-To: <1500061369-27918-1-git-send-email-gvrose8192@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gvrose8192@gmail.com>
Date: Fri, 14 Jul 2017 12:42:49 -0700

> When there is an established connection in direction A->B, it is
> possible to receive a packet on port B which then executes
> ct(commit,force) without first performing ct() - ie, a lookup.
> In this case, we would expect that this packet can delete the existing
> entry so that we can commit a connection with direction B->A. However,
> currently we only perform a check in skb_nfct_cached() for whether
> OVS_CS_F_TRACKED is set and OVS_CS_F_INVALID is not set, ie that a
> lookup previously occurred. In the above scenario, a lookup has not
> occurred but we should still be able to statelessly look up the
> existing entry and potentially delete the entry if it is in the
> opposite direction.
> 
> This patch extends the check to also hint that if the action has the
> force flag set, then we will lookup the existing entry so that the
> force check at the end of skb_nfct_cached has the ability to delete
> the connection.
> 
> Fixes: dd41d330b03 ("openvswitch: Add force commit.")
> CC: Pravin Shelar <pshelar@nicira.com>
> CC: dev@openvswitch.org
> Signed-off-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Greg Rose <gvrose8192@gmail.com>

Applied, thanks.
