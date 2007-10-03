From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Wed, 3 Oct 2007 10:10:51 -0400
Message-ID: <20071003141051.GA5790@tuxdriver.com>
References: <20071003012552.GE29361@tuxdriver.com> <20071002.190156.41633562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071002.190156.41633562.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 07:01:56PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Tue, 2 Oct 2007 21:25:52 -0400
> 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem
> 
> This doesn't pull cleanly.
> 
> Probably you used a recently cloned Linus tree, pulled
> net-2.6.24 into that (and resolved the conflicts), and
> then put your patches in.

No, in fact I'm quite conscious of that.  I follow a procedure
identical to what you outlined.  I even leave my 'master-davem' branch
available as a reference, and create the initial 'upstream-davem'
branch as a checkout from it. :-)

As an experiment, I cloned your current tree (which has the patches
applied already, thanks!) and created a branch which backed-out the
patches from me you had already applied by hand.  I then did a pull
from my tree, and the results were quite clean.

	[linville]:> git checkout -b jwltest fc26d79bb258b5fdb3dee940bea12d6ef7c217c5
	Switched to a new branch "jwltest"

	[linville]:> git pull git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem
	remote: Generating pack...
	remote: Done counting 257 objects.
	remote: Result has 199 objects.
	remote: Deltifying 199 objects...
	remote:  100% (199/199) done
	Indexing 199 objects...
	remote: Total 199 (delta 150), reused 143 (delta 115)
	 100% (199/199) done
	Resolving 150 deltas...
	 100% (150/150) done
	32 objects were added to complete this thin pack.
	Removed drivers/net/wireless/zd1211rw/zd_util.c
	Removed drivers/net/wireless/zd1211rw/zd_util.h
	Merge made by recursive.
	 Documentation/networking/mac80211-injection.txt |   32 ++-
	 drivers/net/wireless/adm8211.c                  |    8 +-
	 drivers/net/wireless/b43/Kconfig                |   12 +
	 drivers/net/wireless/b43/Makefile               |    5 +-
	 drivers/net/wireless/b43/b43.h                  |   11 +-
	 drivers/net/wireless/b43/leds.c                 |  399 ++++++++++-------------
	 drivers/net/wireless/b43/leds.h                 |   63 ++--
	 drivers/net/wireless/b43/main.c                 |  205 ++++--------
	 drivers/net/wireless/b43/phy.c                  |   13 +-
	 drivers/net/wireless/b43/phy.h                  |    2 +-
	 drivers/net/wireless/b43/rfkill.c               |  184 +++++++++++
	 drivers/net/wireless/b43/rfkill.h               |   58 ++++
	 drivers/net/wireless/hostap/hostap.h            |    2 +-
	 drivers/net/wireless/hostap/hostap_hw.c         |    2 +-
	 drivers/net/wireless/hostap/hostap_main.c       |   19 +-
	 drivers/net/wireless/iwlwifi/iwl3945-base.c     |    4 -
	 drivers/net/wireless/iwlwifi/iwl4965-base.c     |    4 -
	 drivers/net/wireless/p54common.c                |    4 +-
	 drivers/net/wireless/p54pci.c                   |    4 +-
	 drivers/net/wireless/rt2x00/rt2x00.h            |    2 +-
	 drivers/net/wireless/zd1211rw/Makefile          |    2 +-
	 drivers/net/wireless/zd1211rw/zd_chip.c         |    1 -
	 drivers/net/wireless/zd1211rw/zd_mac.c          |    4 +-
	 drivers/net/wireless/zd1211rw/zd_usb.c          |    1 -
	 drivers/net/wireless/zd1211rw/zd_util.c         |   82 -----
	 drivers/net/wireless/zd1211rw/zd_util.h         |   29 --
	 include/linux/rfkill.h                          |   24 ++
	 include/net/mac80211.h                          |   46 +++-
	 net/mac80211/cfg.c                              |   75 ++++-
	 net/mac80211/ieee80211.c                        |  189 +-----------
	 net/mac80211/ieee80211_i.h                      |   17 +-
	 net/mac80211/ieee80211_iface.c                  |   68 +----
	 net/mac80211/ieee80211_ioctl.c                  |   31 +-
	 net/mac80211/ieee80211_led.c                    |   67 +++-
	 net/mac80211/ieee80211_led.h                    |    6 +
	 net/mac80211/ieee80211_rate.c                   |    3 +-
	 net/mac80211/ieee80211_rate.h                   |    2 -
	 net/mac80211/ieee80211_sta.c                    |    7 +-
	 net/mac80211/key.c                              |    1 -
	 net/mac80211/rx.c                               |  122 +++-----
	 net/mac80211/sta_info.c                         |   13 +-
	 net/mac80211/tx.c                               |  211 ++++++------
	 net/mac80211/wme.c                              |   10 +-
	 net/rfkill/Kconfig                              |    7 +
	 net/rfkill/rfkill.c                             |   49 +++-
	 45 files changed, 1022 insertions(+), 1078 deletions(-)
	 create mode 100644 drivers/net/wireless/b43/rfkill.c
	 create mode 100644 drivers/net/wireless/b43/rfkill.h
	 delete mode 100644 drivers/net/wireless/zd1211rw/zd_util.c
	 delete mode 100644 drivers/net/wireless/zd1211rw/zd_util.h

So I'm not sure what happened for you.  But I think it must have been
some other anomaly.

Anyway, I'm sorry it wasn't as smooth as usual.  Thanks for the manual
patch work!

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
