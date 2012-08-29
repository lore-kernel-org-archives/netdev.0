From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 0/2] Add rtnl_link_ops support to IPoIB
Date: Wed, 29 Aug 2012 12:41:00 +0300
Message-ID: <503DE3AC.30701@mellanox.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:38961 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750995Ab2H2Joy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 05:44:54 -0400
In-Reply-To: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/08/2012 15:15, Or Gerlitz wrote:
> This is about adding rtnl_link_ops to IPoIB, primarly addressing feedback from Dave on a similar patch that was part of the eIPoIB submission.

Dave, Roland

Any comment on this? The patch was originally submitted through netdev 
so I kept the fixed version to go through that path as well. If this 
makes things easier, we can merge that through net-next.

IPoIB has more proprietary sysfs entries, such as for setting the mode 
(datagram or connected) -- in 2nd thought, non legacy ipoib child 
interfaces created through rtnl shouldn't preserve these prop. 
mechanisms and use rtnl for all sorts of configs, as done for 
macvlan/8021q etc devices, correct? if this is indeed the case, I will 
fix that and submit V3.

Or.

>
> Also added the releated iproute2 patch, for the sake of the review and
> testing, e.g example usages:
>
> $ ip link add link ib0 name ib0.1 type ipoib
> $ ip link add link ib0 name ib0.8001 type ipoib pkey 0x8001
>
> and the obvious
>
> $ link delete dev ib0.8001
> $ link delete dev ib0.1
>
> Changes from V2:
>   - removed the notion of user defined index per child, since we can do well w.o it
>   - for that end, make (an internal to ipoib) distrinction between legacy childs created
>     through the old sysfs way to childs created using rtnl link ops
>
> Changes from V1:
>   - applied feedback from Dave Miller to avoid using sysfs
>   - added rtnl_link_ops support in ipoib and use them to add/delete childs
>
> Or Gerlitz (1):
>    IB/ipoib: Add rtnl_link_ops support
>
>   Documentation/infiniband/ipoib.txt           |    3 +
>   drivers/infiniband/ulp/ipoib/Makefile        |    3 +-
>   drivers/infiniband/ulp/ipoib/ipoib.h         |   13 +++
>   drivers/infiniband/ulp/ipoib/ipoib_main.c    |   25 ++++-
>   drivers/infiniband/ulp/ipoib/ipoib_netlink.c |  122 ++++++++++++++++++++++++++
>   drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |  102 ++++++++++++----------
>   6 files changed, 217 insertions(+), 51 deletions(-)
>   create mode 100644 drivers/infiniband/ulp/ipoib/ipoib_netlink.c
>
