From: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Subject: [PATCH] mac80211: fix GCC warning on 64bit platforms
Date: Mon, 16 Jul 2007 18:46:53 +0200
Message-ID: <20070716184653.355253bf@griffin.suse.cz>
References: <20070712204137.GB14486@tuxdriver.com>
	<20070714.185935.18577806.davem@davemloft.net>
	<20070714.204116.23012949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070714.204116.23012949.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

net/mac80211/ieee80211.c: In function ieee80211_register_hw:
net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast

Fix by casting from size_t to unsigned as size of ieee80211_tx_status_rtap_hdr
structure will never be greater than that.

Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>

---

On Sat, 14 Jul 2007 20:41:16 -0700 (PDT), David Miller wrote:
> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Sat, 14 Jul 2007 18:59:35 -0700 (PDT)
> 
> > From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> > Date: Thu, 12 Jul 2007 16:41:38 -0400
> > 
> > > This request is based off net-2.6, as it requires a patch that is in
> > > net-2.6 but not yet in Linus' tree (b3d88ad49a0623d09efcf998beb26288c8029f75).
> >  ...
> > >   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem
> > 
> > Pulled, thanks John!
> 
> A warning to look into:
> 
> net/mac80211/ieee80211.c: In function $,1rxieee80211_register_hw$,1ry:
> net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast

---
 net/mac80211/ieee80211.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mac80211-2.6.orig/net/mac80211/ieee80211.c
+++ mac80211-2.6/net/mac80211/ieee80211.c
@@ -4987,7 +4987,7 @@ int ieee80211_register_hw(struct ieee802
 	 * interfaces, but never both at the same time.
 	 */
 	local->tx_headroom = max(local->hw.extra_tx_headroom,
-				 sizeof(struct ieee80211_tx_status_rtap_hdr));
+				 (unsigned)sizeof(struct ieee80211_tx_status_rtap_hdr));
 
 	debugfs_hw_add(local);
 

-- 
Jiri Benc
SUSE Labs
