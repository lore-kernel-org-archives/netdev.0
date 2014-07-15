From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] bonding: add proper __rcu annotation for
 curr_active_slave
Date: Tue, 15 Jul 2014 12:52:49 +0200
Message-ID: <1405421569.10255.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
	 <1405417604-7828-4-git-send-email-edumazet@google.com>
	 <20140715103858.GD28235@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:52182 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758643AbaGOKw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 06:52:58 -0400
Received: by mail-we0-f170.google.com with SMTP id w62so5124876wes.1
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 03:52:52 -0700 (PDT)
In-Reply-To: <20140715103858.GD28235@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-15 at 12:38 +0200, Veaceslav Falico wrote:
> On Tue, Jul 15, 2014 at 02:46:44AM -0700, Eric Dumazet wrote:
> >RCU was added to bonding in linux-3.12 but lacked proper sparse annotations.
> >
> >Using __rcu annotation actually helps to spot all accesses to bond->curr_active_slave
> >are correctly protected, with LOCKDEP support.
> >
> >Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks a lot for cleaning this up, it's really a huge mess here...
> 
> One question though:
> 
> ...snip...
> >@@ -2046,7 +2051,7 @@ static void bond_miimon_commit(struct bonding *bond)
> > 				bond_alb_handle_link_change(bond, slave,
> > 							    BOND_LINK_DOWN);
> >
> >-			if (slave == bond->curr_active_slave)
> >+			if (slave == rcu_access_pointer(bond->curr_active_slave))
> 
> I guess you've meant rtnl_dereference()? As bond_miimon_commit() is ujnder
> rtnl, not under rcu.

This does not really matter here, as we only perform an equality test.

(We dont read the pointer, then dereference it)

rcu_access_pointer() is fine in this context, this makes sparse happy
mostly.
