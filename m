From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/3] bonding: rcu cleanups
Date: Tue, 15 Jul 2014 12:55:19 +0200
Message-ID: <53C50897.2020605@redhat.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932516AbaGOKz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 06:55:29 -0400
In-Reply-To: <1405417604-7828-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 11:46 AM, Eric Dumazet wrote:
> RCU was added to bonding in linux-3.12 but lacked proper sparse annotations.
> 
> Using __rcu annotation actually helps to spot all accesses to bond->curr_active_slave
> are correctly protected, with full sparse & LOCKDEP support.
> 
> Lets clean the code.
> 
> Eric Dumazet (3):
>   bonding: get rid of bond_option_active_slave_get()
>   bonding: use rcu_access_pointer() in bonding_show_mii_status()
>   bonding: add proper __rcu annotation for curr_active_slave
> 
>  drivers/net/bonding/bond_alb.c     | 47 +++++++++++++++++++--------------
>  drivers/net/bonding/bond_main.c    | 53 +++++++++++++++++++++-----------------
>  drivers/net/bonding/bond_netlink.c | 21 +++++++++++----
>  drivers/net/bonding/bond_options.c |  7 +----
>  drivers/net/bonding/bond_sysfs.c   |  3 ++-
>  drivers/net/bonding/bonding.h      |  7 +++--
>  6 files changed, 81 insertions(+), 57 deletions(-)
> 
Nice clean up, I also gave it a quick run. I believe similar clean up would
be beneficial for current_arp_slave at some point.

Anyhow, thanks Eric!

For the set
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
