From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Wed, 10 Oct 2007 21:16:54 -0700 (PDT)
Message-ID: <20071010.211654.85404234.davem@davemloft.net>
References: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58046
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751846AbXJKEQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:16:51 -0400
In-Reply-To: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 28 Sep 2007 18:59:08 -0600

> 
> Currently we have the call path:
> macvlan_open -> dev_unicast_add -> __dev_set_rx_mode ->
> 	__dev_set_promiscuity -> ASSERT_RTNL -> mutex_trylock
> 
> When mutex debugging is on taking a mutex complains if we are not
> allowed to sleep.  At that point we have called netif_tx_lock_bh
> so we are clearly not allowed to sleep.  Arguably this is not a
> problem for mutex_trylock.
> 
> However we can avoid the complaint and make the ASSERT_RTNL code
> cheaper, faster and more obvious by simply calling mutex_is_locked.
> 
> So this patch adds rtnl_is_locked (which does mutex_is_locked on
> the rtnl_mutex) and changes ASSERT_RTNL to use that.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

There was a lot of discussion about how to do this right and
therefore you'll need to resubmit all of this with this
discussioned issues addressed.
