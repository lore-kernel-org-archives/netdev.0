From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH v2 net-next 0/4] bonding: rcu cleanups
Date: Tue, 15 Jul 2014 16:37:15 +0200
Message-ID: <20140715143714.GB5225@mikrodark.usersys.redhat.com>
References: <1405432616-12414-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:61176 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbaGOOkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 10:40:13 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so3576384wgh.10
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 07:40:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405432616-12414-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:56:52AM -0700, Eric Dumazet wrote:
>RCU was added to bonding in linux-3.12 but lacked proper sparse annotations.
>
>Using __rcu annotation actually helps to spot all accesses to
>bond->curr_active_slave & cond->current_arp_slave
>are correctly protected, with full sparse & LOCKDEP support.
>
>Lets clean the code.

Awesome work, thank you!

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>
>Eric Dumazet (4):
>  bonding: get rid of bond_option_active_slave_get()
>  bonding: use rcu_access_pointer() in bonding_show_mii_status()
>  bonding: add proper __rcu annotation for curr_active_slave
>  bonding: add proper __rcu annotation for current_arp_slave
>
> drivers/net/bonding/bond_alb.c     | 47 +++++++++++++++-----------
> drivers/net/bonding/bond_main.c    | 68 +++++++++++++++++++++-----------------
> drivers/net/bonding/bond_netlink.c | 21 +++++++++---
> drivers/net/bonding/bond_options.c |  7 +---
> drivers/net/bonding/bond_sysfs.c   |  3 +-
> drivers/net/bonding/bonding.h      |  9 +++--
> 6 files changed, 91 insertions(+), 64 deletions(-)
>
>-- 
>2.0.0.526.g5318336
>
