From: "Sean Hefty" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Wed, 11 Nov 2009 10:18:47 -0800
Message-ID: <D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com>
References: <4AF8EBA4.2070102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev List" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Roland Dreier" <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"Hal Rosenstock" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "'Eric Dumazet'" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AF8EBA4.2070102-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>for_each_netdev() should be used with RTNL or dev_base_lock held,
>or risk a crash.
>
>Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks - I'm working on a patch set in this area.  Roland, I can merge Eric's
changes into that patch set if it makes things easier.

> drivers/infiniband/core/addr.c |    9 +++++++--
> 1 files changed, 7 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
>index bd07803..5ca0b2c 100644
>--- a/drivers/infiniband/core/addr.c
>+++ b/drivers/infiniband/core/addr.c
>@@ -131,6 +131,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct

The changes to this function are still valid.

>@@ -391,15 +393,17 @@ static int addr_resolve_local(struct sockaddr *src_in,

This function is going away.

- Sean

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
