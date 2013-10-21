From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/5] bonding: patchset for rcu use in bonding
Date: Mon, 21 Oct 2013 11:13:36 +0200
Message-ID: <20131021091336.GB692@redhat.com>
References: <5264ECBC.2090208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978Ab3JUJSC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 05:18:02 -0400
Content-Disposition: inline
In-Reply-To: <5264ECBC.2090208@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 04:58:36PM +0800, Ding Tianhong wrote:
>Hi:
>
>The Patch Set will remove the invalid lock for bond work queue and replace it
>with rtnl lock, as read lock for bond could not protect slave list any more.

rtnl lock is a lot more expensive than bond lock, and not only for bond,
but for all the networking stack.

Why is the bond->lock invalid? It correctly protects slaves from being
modified concurrently.

I don't see the point in this patchset.

>
>Ding Tianhong (5):
>  bonding: remove bond read lock for bond_mii_monitor()
>  bonding: remove bond read lock for bond_alb_monitor()
>  bonding: remove bond read lock for bond_loadbalance_arp_mon()
>  bonding: remove bond read lock for bond_activebackup_arp_mon()
>  bonding: remove bond read lock for bond_3ad_state_machine_handler()
>
> drivers/net/bonding/bond_3ad.c  |   9 ++--
> drivers/net/bonding/bond_alb.c  |  20 ++------
> drivers/net/bonding/bond_main.c | 100 +++++++++++++---------------------------
> 3 files changed, 40 insertions(+), 89 deletions(-)
>
>-- 
>1.8.2.1
>
>
>
