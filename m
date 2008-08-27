From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure
Date: Wed, 27 Aug 2008 14:54:49 +1000
Message-ID: <20080827145449.2790d97d.sfr@canb.auug.org.au>
References: <20080827100656.0f87e6b2.sfr@canb.auug.org.au>
	<200808271255.22789.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-next@vger.kernel.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <200808271255.22789.rusty@rustcorp.com.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rusty,

On Wed, 27 Aug 2008 12:55:22 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
>
> On Wednesday 27 August 2008 10:06:56 Stephen Rothwell wrote:
> > Introduced by commit 4cb9da6ecc2b0e25056b45981239475f8509d59d ("remove
> > CONFIG_KMOD from net") which added a !CONFIG_MODULES (static inline)
> > version of dev_load() to include/linux/netdevice.h but the copy in
> > net/core/dev.c is not protected by CONFIG_MODULES.
> 
> Thanks.  I've fixed this the simplest way: remove the change to the header.

So, for today, I have applied the following patch after importing the rr
tree:

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 27 Aug 2008 14:45:37 +1000
Subject: [PATCH] rr: build fix for remove CONFIG_KMOD from net

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/netdevice.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b215744..2254eb8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1639,11 +1639,7 @@ extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
-#ifdef CONFIG_MODULES
 extern void		dev_load(struct net *net, const char *name);
-#else
-static inline void	dev_load(struct net *net, const char *name) {};
-#endif
 extern void		dev_mcast_init(void);
 extern int		netdev_max_backlog;
 extern int		weight_p;
-- 
1.5.6.5
