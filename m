From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6 merged into net-next-2.6
Date: Tue, 10 Jun 2008 13:47:13 -0400
Message-ID: <20080610174713.GA24763@tuxdriver.com>
References: <20080610.025059.37807108.davem@davemloft.net> <20080610160212.GA16834@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4523 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047AbYFJS3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 14:29:06 -0400
Content-Disposition: inline
In-Reply-To: <20080610160212.GA16834@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2008 at 12:02:12PM -0400, John W. Linville wrote:
> On Tue, Jun 10, 2008 at 02:50:59AM -0700, David Miller wrote:
> > 
> > There were a few small wireless conflicts but I think
> > I handled them correctly.
> > 
> > Please send me any fixup patches which might be necessary.
> 
> Just one, which was easy to miss:

Oops, found another one...

The following changes since commit 65b53e4cc90e59936733b3b95b9451d2ca47528d:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../davem/net-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

John W. Linville (2):
      rt2x00dev.c: fix-up merge damage
      net/mac80211/ieee80211_i.h: fix-up merge damage

 drivers/net/wireless/rt2x00/rt2x00dev.c |    2 +-
 net/mac80211/ieee80211_i.h              |   21 ---------------------
 2 files changed, 1 insertions(+), 22 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index f7a4417..dc5ab90 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -507,7 +507,7 @@ void rt2x00lib_txdone(struct queue_entry *entry,
 	rt2x00dev->link.qual.tx_success +=
 	    test_bit(TXDONE_SUCCESS, &txdesc->flags);
 	rt2x00dev->link.qual.tx_failed +=
-	    txdesc->retry + !!test_bit(TXDONE_FAILURE, &txdesc->flags);
+	    test_bit(TXDONE_FAILURE, &txdesc->flags);
 
 	/*
 	 * Initialize TX status
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 884be4d..b19bd16 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -853,27 +853,6 @@ u32 ieee80211_handle_ht(struct ieee80211_local *local, int enable_ht,
 
 /* ieee80211_ioctl.c */
 extern const struct iw_handler_def ieee80211_iw_handler_def;
-
-/* Least common multiple of the used rates (in 100 kbps). This is used to
- * calculate rate_inv values for each rate so that only integers are needed. */
-#define CHAN_UTIL_RATE_LCM 95040
-/* 1 usec is 1/8 * (95040/10) = 1188 */
-#define CHAN_UTIL_PER_USEC 1188
-/* Amount of bits to shift the result right to scale the total utilization
- * to values that will not wrap around 32-bit integers. */
-#define CHAN_UTIL_SHIFT 9
-/* Theoretical maximum of channel utilization counter in 10 ms (stat_time=1):
- * (CHAN_UTIL_PER_USEC * 10000) >> CHAN_UTIL_SHIFT = 23203. So dividing the
- * raw value with about 23 should give utilization in 10th of a percentage
- * (1/1000). However, utilization is only estimated and not all intervals
- * between frames etc. are calculated. 18 seems to give numbers that are closer
- * to the real maximum. */
-#define CHAN_UTIL_PER_10MS 18
-#define CHAN_UTIL_HDR_LONG (202 * CHAN_UTIL_PER_USEC)
-#define CHAN_UTIL_HDR_SHORT (40 * CHAN_UTIL_PER_USEC)
-
-
-/* ieee80211_ioctl.c */
 int ieee80211_set_freq(struct net_device *dev, int freq);
 
 /* ieee80211_sta.c */
-- 
John W. Linville
linville@tuxdriver.com
