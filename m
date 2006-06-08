From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/12] d80211: use sysfs instead of procfs
Date: Thu,  8 Jun 2006 09:49:03 +0200 (CEST)
Message-ID: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50584 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932557AbWFHHrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:47:53 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series of patches makes d80211 to use sysfs instead of procfs.
This means that custom reference counting in most structures is replaced by
kobjects and nearly all informations from procfs files are converted to
sysfs attributes.

The only information missing in sysfs (compared to procfs) is channels and
rates info. Implementing this in a sysfs way (i. e. one information per
attribute rule) requires a lot of code and (more important) adding kobjects
to channel and rate structures. I doubt these informations are really so
useful to be worth such complications. If there are good arguments why these
informations should be exported via sysfs I will add them.

If you find a better name for some object (directory) or attribute (file) or
just consider some name wrong or ugly, let me know please.

The third patch ("separate allocation of ieee80211_local") touches the code
outside of net/d80211 - it adds ieee80211_ptr to net_device structure.

All of patches can be also obtained from 'master' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git

---

Jiri Benc:
      d80211: deinit sysfs in case of an error
      d80211: better sysfs registration of symlinks to wiphy
      d80211: separate allocation of ieee80211_local
      d80211: fix Oops when writing to add_ and remove_iface
      d80211: wiphy sysfs attributes
      d80211: network interface sysfs attributes
      d80211: rename sta_info_relase to sta_info_put
      d80211: sysfs attributes for associated stations
      d80211: remove useless parameters
      d80211: rate_control sysfs attributes
      d80211: encryption keys sysfs attributes
      d80211: remove procfs files

 include/linux/netdevice.h        |    1 
 net/d80211/Makefile              |    2 
 net/d80211/ieee80211.c           |  206 +++++++---
 net/d80211/ieee80211_dev.c       |   17 +
 net/d80211/ieee80211_i.h         |   45 ++
 net/d80211/ieee80211_iface.c     |   43 +-
 net/d80211/ieee80211_ioctl.c     |  213 ++++++----
 net/d80211/ieee80211_key.h       |    2 
 net/d80211/ieee80211_proc.c      |  771 --------------------------------------
 net/d80211/ieee80211_proc.h      |   45 --
 net/d80211/ieee80211_scan.c      |   10 
 net/d80211/ieee80211_sta.c       |   68 ++-
 net/d80211/ieee80211_sysfs.c     |  706 +++++++++++++++++++++++++++++++++--
 net/d80211/ieee80211_sysfs_sta.c |  434 +++++++++++++++++++++
 net/d80211/rate_control.c        |   55 ++-
 net/d80211/rate_control.h        |   57 ++-
 net/d80211/sta_info.c            |  132 ++++---
 net/d80211/sta_info.h            |   16 -
 net/d80211/wme.c                 |   26 +
 19 files changed, 1663 insertions(+), 1186 deletions(-)


-- 
Jiri Benc
SUSE Labs
