From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 0/12]: Proper compat WEXT support.
Date: Mon, 16 Jun 2008 18:15:12 +0900
Message-ID: <20080616174509.B048.40F06B3A@sm.sony.co.jp>
References: <20080604184955.B033.40F06B3A@sm.sony.co.jp> <20080612.225332.193703791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080612.225332.193703791.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Thu, 12 Jun 2008 22:53:32 -0700 (PDT)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> Here is a new version of patch 12, which should fix the problems
> you reported here.  The idea is simple, all references to
> IW_EV_LCP_LEN are replaced with calls to a new inline function
> named iwe_stream_lcp_len() which returns the compat value if
> necessary.
> 
> wext: Emit event stream entries correctly when compat.
> 
> Three major portions to this change:
> 
> 1) Add IW_EV_COMPAT_LCP_LEN, IW_EV_COMPAT_POINT_OFF,
>    and IW_EV_COMPAT_POINT_LEN helper defines.
> 
> 2) Delete iw_stream_check_add_*(), they are unused.
> 
> 3) Add iw_request_info argument to iwe_stream_add_*(), and use it to
>    size the event and pointer lengths correctly depending upon whether
>    IW_REQUEST_FLAG_COMPAT is set or not.
> 
> 4) The mechanical transformations to the drivers and wireless stack
>    bits to get the iw_request_info passed down into the routines
>    modified in #3.  Also, explicit references to IW_EV_LCP_LEN are
>    replaced with iwe_stream_lcp_len(info).
> 
> With a lot of help and bug fixes from Masakazu Mokuno.
> 
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  drivers/net/ps3_gelic_wireless.c           |   30 +++---
>  drivers/net/wireless/airo.c                |   43 +++++---
>  drivers/net/wireless/atmel.c               |   24 ++++-
>  drivers/net/wireless/hostap/hostap.h       |    3 +-
>  drivers/net/wireless/hostap/hostap_ap.c    |   32 +++---
>  drivers/net/wireless/hostap/hostap_ioctl.c |   58 ++++++-----
>  drivers/net/wireless/libertas/scan.c       |   36 ++++---
>  drivers/net/wireless/orinoco.c             |   23 +++--
>  drivers/net/wireless/prism54/isl_ioctl.c   |   49 +++++----
>  drivers/net/wireless/rndis_wlan.c          |   31 +++---
>  drivers/net/wireless/wl3501_cs.c           |   10 +-
>  drivers/net/wireless/zd1201.c              |   21 +++--
>  include/linux/wireless.h                   |   15 +++
>  include/net/iw_handler.h                   |  149 +++++++++-------------------
>  net/ieee80211/ieee80211_wx.c               |   48 +++++----
>  net/mac80211/ieee80211_i.h                 |    5 +-
>  net/mac80211/mlme.c                        |   45 +++++----
>  net/mac80211/wext.c                        |    2 +-
>  18 files changed, 323 insertions(+), 301 deletions(-)

Thank you again for updating the patch set!

With this new patch #12, it worked OK for me.   I tested on my PS3 with:

  - wireless_tools version 28 and 29.  Both 64 and 32-bit compiled
    iwlist and iwconfig
  - wpa_supplicant 0.6.x, 64 and 32-bit compiled
  - gelic and zd1211 driver
  

checkpatch.pl complained some error/warnings on the patches #7, #9 and
#12.  It seemed that most of them were inherited from the original code,
some seemed like newly created ones, like 80-characters over warnings in
net/mac80211/mlme.c.  We might want to fix them?

Anyway the code works fine.  Again, thank you!

-- 
Masakazu Mokuno

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
