From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] net, wireless: Don't return uninitialized in
 __cfg80211_stop_sched_scan()
Date: Wed, 29 Jun 2011 22:42:25 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106292241230.3747@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1106292212110.3747@swampdragon.chaosbits.net>  <1309379244.4071.7.camel@jlt3.sipsolutions.net> <1309379630.1514.122.camel@cumari>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309379630.1514.122.camel@cumari>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Jun 2011, Luciano Coelho wrote:

> On Wed, 2011-06-29 at 22:27 +0200, Johannes Berg wrote: 
> > On Wed, 2011-06-29 at 22:13 +0200, Jesper Juhl wrote:
> > > If the 'driver_initiated' function argument to
> > > __cfg80211_stop_sched_scan() is not 0 then we'll return an
> > > uninitialized 'ret' from the function.
> > 
> > 'err'. I also dislike the initialisation, can we just replace the
> > "return err;" at the end of the function with "return 0;" instead?
> 
> Luckily we were never using the return value when passing
> driver_initiate =- false.
> 
> And I agree with you, there's no use to return err at the end.  Better
> to simply return 0.
> 
Ok, so how about this?

>From 606ee120df85dbd5205996878f50e51b8b7cd4a3 Mon Sep 17 00:00:00 2001
From: Jesper Juhl <jj@chaosbits.net>
Date: Wed, 29 Jun 2011 22:49:33 +0200
Subject: [PATCH] net, wireless: Don't return uninitialized in
 __cfg80211_stop_sched_scan()

If the 'driver_initiated' function argument to
__cfg80211_stop_sched_scan() is not 0 then we'll return an
uninitialized 'err' from the function.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/wireless/scan.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 7a6c676..5d23503 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -132,7 +132,6 @@ EXPORT_SYMBOL(cfg80211_sched_scan_stopped);
 int __cfg80211_stop_sched_scan(struct cfg80211_registered_device *rdev,
 			       bool driver_initiated)
 {
-	int err;
 	struct net_device *dev;
 
 	ASSERT_RDEV_LOCK(rdev);
@@ -143,7 +142,7 @@ int __cfg80211_stop_sched_scan(struct cfg80211_registered_device *rdev,
 	dev = rdev->sched_scan_req->dev;
 
 	if (!driver_initiated) {
-		err = rdev->ops->sched_scan_stop(&rdev->wiphy, dev);
+		int err = rdev->ops->sched_scan_stop(&rdev->wiphy, dev);
 		if (err)
 			return err;
 	}
@@ -153,7 +152,7 @@ int __cfg80211_stop_sched_scan(struct cfg80211_registered_device *rdev,
 	kfree(rdev->sched_scan_req);
 	rdev->sched_scan_req = NULL;
 
-	return err;
+	return 0;
 }
 
 static void bss_release(struct kref *ref)
-- 
1.7.6

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
