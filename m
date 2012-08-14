From: Andy Gospodarek <gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch net-next v2 00/15] net: introduce upper device lists and
 remove dev->master
Date: Tue, 14 Aug 2012 16:19:50 -0400
Message-ID: <20120814201950.GA17781@quad.redhat.com>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
	divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1344956748-2099-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2012 at 05:05:33PM +0200, Jiri Pirko wrote:
> Hi all.
> 
> Recent discussion around
> "[net-next] bonding: don't allow the master to become its slave"
> forced me to think about upper<->lower device connections.
> 
> This patchset adds a possibility to record upper device linkage.
> All upper<->lower devices are converted to use this mechanism right after.
> That leads to dev->master removal because this info becomes redundant since
> "unique links" have the same value.
> 
> After all changes, there is no longer possible to do:
> "bond->someotherdevice->samebond"
> 
> Also I think that drivers like cxgb3, qlcnic, qeth would benefit by this
> in future by being able to get more appropriate info about l3 addresses.
> 
> v1->v2:
> - s/unique/master/ better naming + stays closer to the history
> - fixed vlan err goto
> - original patch 15 (WARN_ON change) is squashed into the first patch
> - fixed netdev_unique_upper_dev_get_rcu() case of upper==NULL
I just started to review v1 when v2 came out, but luckily the changes
were not too significant that I need to start all over.

The first note is that I didn't like the use of the term 'upper' -- it
seems like 'stacked' might be a better alternative as these are stacked
devices.

One thing to note is that I don't see any clear changelog that states
the current goals for this.  You have stated in several places that it
will no longer be possible to create bonds of bonds, but there are
probably a few more things it might be wise to intentionally outlaw.

What about teams of teams?  Or teams of bonds?  Or bonds of teams?
Bonds of vlans?

> 
> Jiri Pirko (15):
>   net: introduce upper device lists
>   macvlan: add link to upper device
>   vlan: add link to upper device
>   rtnetlink: remove usage of dev->master
>   team: remove usage of netdev_set_master()
>   bridge: remove usage of netdev_set_master()
>   netpoll: remove usage of dev->master
>   cxgb3: remove usage of dev->master
>   qlcnic: guard __vlan_find_dev_deep() by rcu_read_lock
>   qeth: ensure that __vlan_find_dev_deep() is called with rcu_read_lock
>   vlan: remove usage of dev->master in __vlan_find_dev_deep()
>   nes: remove usage of dev->master
>   bonding: remove usage of dev->master
>   net: remove no longer used netdev_set_bond_master() and
>     netdev_set_master()
>   net: kill dev->master
> 
>  drivers/infiniband/hw/nes/nes.c                    |    8 +-
>  drivers/infiniband/hw/nes/nes_cm.c                 |    2 +-
>  drivers/net/bonding/bond_3ad.c                     |   30 +--
>  drivers/net/bonding/bond_alb.c                     |    6 +-
>  drivers/net/bonding/bond_main.c                    |   94 ++++----
>  drivers/net/bonding/bonding.h                      |   14 +-
>  drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   11 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +
>  drivers/net/macvlan.c                              |    9 +-
>  drivers/net/team/team.c                            |   13 +-
>  drivers/s390/net/qeth_l3_main.c                    |   21 +-
>  include/linux/netdevice.h                          |   22 +-
>  net/8021q/vlan.c                                   |   10 +-
>  net/8021q/vlan_core.c                              |   18 +-
>  net/bridge/br_if.c                                 |    6 +-
>  net/core/dev.c                                     |  239 +++++++++++++++++---
>  net/core/netpoll.c                                 |    8 +-
>  net/core/rtnetlink.c                               |   45 ++--
>  18 files changed, 391 insertions(+), 167 deletions(-)
> 
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
