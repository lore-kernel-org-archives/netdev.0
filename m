From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Please pull 'fixes-davem' branch of wireless-2.6
Date: Wed, 7 Nov 2007 13:51:54 -0500
Message-ID: <20071107185147.GA21097@tuxdriver.com>
References: <20071107001314.GH4440@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071107001314.GH4440-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Hold-off on this one for now if -- clearly Johannes and I need to
brush-up on our Kconfig skills... :-(

I'll post a new pull request soon.

Thanks,

John

On Tue, Nov 06, 2007 at 07:13:14PM -0500, John W. Linville wrote:
> Dave,
> 
> Here are some fixes for 2.6.24...
> 
> The iwlwifi patch is needed because the iwlwifi drivers routinely end-up
> associated with the "simple" rate control algorithm, yet those drivers
> really only work with their own custom algorithms.  The other rate
> control patches are there to satisfy dependencies for this patch.
> 
> "mac80211: remove ieee80211_common.h" cleans-up an unused file left
> hanging-around after an earlier patch already in 2.6.24.
> 
> "mac80211: remove unused driver ops" is really a clean-up, but
> "mac80211: use IW_AUTH_PRIVACY_INVOKED rather than IW_AUTH_KEY_MGMT"
> depends on it.
> 
> "ssb: Fix initcall ordering" changes a subsys_initcall to an
> fs_initcall.  This seems like a bit of a hack, but it fixes a real
> problem and I'm not sure what cleaner solution is either reasonable
> or available.  The comment in the patch explains the reasoning for this
> somewhat unique situation.
> 
> I think the other patches are plain enough to not require further
> comment.  Let me know if there are any problems!
> 
> Thanks,
> 
> John
> 
> ---
> 
> Individual patches are available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem/
> 
> ---
> 
> The following changes since commit 2655e2cee2d77459fcb7e10228259e4ee0328697:
>   Alan Cox (1):
>         ata_piix: Add additional PCI identifier for 40 wire short cable
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem
> 
> Johannes Berg (9):
>       softmac: fix wext MLME request reason code endianness
>       mac80211: make simple rate control algorithm built-in
>       mac80211: don't allow registering the same rate control twice
>       mac80211: allow driver to ask for a rate control algorithm
>       iwlwifi: select proper rate control algorithm
>       softmac: MAINTAINERS update
>       mac80211: remove ieee80211_common.h
>       mac80211: remove unused driver ops
>       mac80211: use IW_AUTH_PRIVACY_INVOKED rather than IW_AUTH_KEY_MGMT
> 
> John W. Linville (1):
>       mac80211: make "decrypt failed" messages conditional upon MAC80211_DEBUG
> 
> Michael Buesch (5):
>       ssb: Fix initcall ordering
>       rfkill: Register LED triggers before registering switch
>       rfkill: Use subsys_initcall
>       rfkill: Use mutex_lock() at register and add sanity check
>       rfkill: Fix sparse warning
> 
>  MAINTAINERS                                 |    7 +--
>  drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +
>  drivers/net/wireless/iwlwifi/iwl4965-base.c |    2 +
>  drivers/ssb/main.c                          |    5 +-
>  include/net/mac80211.h                      |   26 ++------
>  net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
>  net/mac80211/Kconfig                        |   12 ++++
>  net/mac80211/Makefile                       |    3 +-
>  net/mac80211/ieee80211.c                    |   16 +++++-
>  net/mac80211/ieee80211_common.h             |   91 ---------------------------
>  net/mac80211/ieee80211_i.h                  |    2 +-
>  net/mac80211/ieee80211_ioctl.c              |   21 +++----
>  net/mac80211/ieee80211_rate.c               |   24 ++++++-
>  net/mac80211/ieee80211_rate.h               |    3 +
>  net/mac80211/ieee80211_sta.c                |   18 +++--
>  net/mac80211/rc80211_simple.c               |   25 +-------
>  net/mac80211/rx.c                           |    2 +
>  net/mac80211/wep.c                          |    2 +
>  net/mac80211/wpa.c                          |   18 ++++--
>  net/rfkill/rfkill.c                         |   37 ++++++-----
>  20 files changed, 126 insertions(+), 192 deletions(-)
>  delete mode 100644 net/mac80211/ieee80211_common.h

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
