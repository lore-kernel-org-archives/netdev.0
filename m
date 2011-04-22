From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: fix deadlock when removing net driver that
 netconsole is using (v2)
Date: Fri, 22 Apr 2011 14:34:08 -0700 (PDT)
Message-ID: <20110422.143408.112583207.davem@davemloft.net>
References: <1303495859-12279-1-git-send-email-nhorman@tuxdriver.com>
	<20110422.114033.104072820.davem@davemloft.net>
	<20110422213145.GA2332@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49117
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756668Ab1DVVem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 17:34:42 -0400
In-Reply-To: <20110422213145.GA2332@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 22 Apr 2011 17:31:45 -0400

> I understand what you're saying here, but I think we're ok in this particular
> case.  I say that because all other callers of __netpoll_cleanup, call it via
> netpoll_cleanup, which does the dev_put under protection of the rtnl_lock.  This
> call is also under the rtnl_lock protection, its just taken when the event
> notification is made (thats why we call __netpoll_cleanup instead of
> netpoll_cleanup).  The target_list_lock just protects the integrity of the
> netconsole_target list.  If someone disables a netconsole via configfs, they'll
> block on the rtnl_lock.  Since no path through configfs takes the
> target_list_lock and rtnl (via netpoll_cleanup) in any nested fashion, we're
> safe from deadlock.

That's right, rtnl saves us.

Thanks for explaining, applied, thanks!
