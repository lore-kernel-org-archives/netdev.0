From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 0/2] bonding: ensure that the TSO being set
 on bond master
Date: Tue, 14 Jan 2014 10:47:41 +0100
Message-ID: <20140114094741.GB20066@redhat.com>
References: <52D4FC97.8020301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbaANJuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 04:50:46 -0500
Content-Disposition: inline
In-Reply-To: <52D4FC97.8020301@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 05:00:07PM +0800, Ding Tianhong wrote:
>The commit b0ce3508(bonding: allow TSO being set on bonding master)
>has make the TSO being set for bond dev, but in some situation, if
>the slave did not have the NETIF_F_SG features, the bond master will
>miss the TSO features in netdev_fix_features because the TSO is
>depended on SG. So I have to add SG and TSO features on bond master
>together.
>
>The function netdev_add_tso_features() was only be used for bonding,
>so no need to export it in netdevice.h, remove it and add it to bonding.
>
>v2: If the slave hw did not support SG features, the SG should not
>    be forced open on master, otherwise error will occur, so modify it.
>    Some slave may support SG but not open it yet, so the bond master
>    could try to open it when adding the salve and make sure the TSO
>    could be open on master.

So you're forcibly enabling SG on a slave? Usually SG is always enabled,
unless there's a very specific reason for that - like a bug in hw/sw/fw,
like performance improvement on specific use-cases etc. etc.

So that's a wrong thing to do - to try to enable it, if it was disabled.

Nacked-by: Veaceslav Falico <vfalico@redhat.com>

>
>Ding Tianhong (2):
>  bonding: move the netdev_add_tso_features() to bonding
>  bonding: try to enable SG features when adding a new slave
>
> drivers/net/bonding/bond_main.c | 27 ++++++++++++++++++++++++++-
> include/linux/netdevice.h       | 10 ----------
> 2 files changed, 26 insertions(+), 11 deletions(-)
>
>-- 
>1.8.0
>
>
