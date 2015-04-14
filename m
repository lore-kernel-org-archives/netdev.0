From: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH linux-next 0/4] fix possile NULL pointer dereference in ndo_get_iflink callback functions
Date: Tue, 14 Apr 2015 23:20:13 +0800
Message-ID: <1429024817-21561-1-git-send-email-honli@redhat.com>
Cc: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


The four callback functions deferference the pointers without test. 
As ipoib_get_iflink failed, it is a good reason to fix the other three
functions. Those functions will return zero on error, as valid ifindex
greater than zero.

I understand that those simple patches should be emerged into a single
patch. However, those files have be maintained by different maintainers.
So, I split it for review. It also will be convenient to remove one or
more patches with the rest not be affected.

Honggang Li (4):
  infiniband/ipoib: fix possible NULL pointer dereference in
 ipoib_get_iflink
  ipvlan: fix possible NULL pointer dereference in ipvlan_get_iflink
  macvlan: fix possible NULL pointer dereference in macvlan_dev_get_iflink
  net/dsa: fix possible NULL pointer dereference in dsa_slave_get_iflink

 drivers/infiniband/ulp/ipoib/ipoib_main.c | 5 ++++-
 drivers/net/ipvlan/ipvlan_main.c          | 5 ++++-
 drivers/net/macvlan.c                     | 4 +++-
 net/dsa/slave.c                           | 5 ++++-
 4 files changed, 15 insertions(+), 4 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
