From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2017-06-13
Date: Tue, 13 Jun 2017 14:22:21 +0200
Message-ID: <20170613122223.2386-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54270 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752608AbdFMMWd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 08:22:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Looks like I haven't sent you anything for a long time, so here
we go. There isn't a ton of things, but in particular the 4-way-
handshake offload has been a long time in the making.

I'll send you the conversion for more skb_put_zero() users in a
separate patch after this.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 50dffe7fad6c156c2928e45c19ff7b86eb951f4c:

  Merge branch 'mlx4-drivers-version-update' (2017-06-07 15:33:02 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2017-06-13

for you to fetch changes up to 4524667b1e6801a92a4de066788e558b71fe323a:

  net: rfkill: gpio: Switch to devm_acpi_dev_add_driver_gpios() (2017-06-13 11:07:51 +0200)

----------------------------------------------------------------
A couple of weeks worth of updates - looks like things are quiet:
 * merged net-next back to get a patch from net that another patch
   here depends on
 * various small improvements/cleanups across the board
 * 4-way handshake offload (many thanks to Arend for shepherding that)
 * mesh CSA/DFS support in mac80211
 * the skb_put_zero() we discussed previously

----------------------------------------------------------------
Andy Shevchenko (1):
      net: rfkill: gpio: Switch to devm_acpi_dev_add_driver_gpios()

Arend Van Spriel (1):
      nl80211: remove desciption about request from NL80211_CMD_ROAM

Avraham Stern (2):
      cfg80211: support 4-way handshake offloading for 802.1X
      nl80211: add authorized flag to ROAM event

Benjamin Berg (4):
      mac80211: mesh: mark channel as unusable if a regulatory MESH CSA is received
      wireless: Only join DFS channels in mesh mode if userspace flags support
      wireless: Require HANDLE_DFS flag to switch channel for non-AP mode
      mac80211: mesh: Allow following CSA to DFS channels if userspace handles it

Bjorn Andersson (1):
      mac80211: Invoke TX LED in more code paths

Eliad Peller (1):
      cfg80211: support 4-way handshake offloading for WPA/WPA2-PSK

Emmanuel Grumbach (1):
      mac80211: add the action to the drv_ampdu_action tracepoint

Johannes Berg (5):
      cfg80211: improve warnings in VHT rate calculation
      mac80211: move clearing result into ieee80211_parse_ch_switch_ie()
      skbuff/mac80211: introduce and use skb_put_zero()
      Merge remote-tracking branch 'net-next/master' into mac80211-next
      mac80211: manage RX BA session offload without SKB queue

Simon Wunderlich (3):
      mac80211: mark as action frame when parsing IEs of CSA action frames
      mac80211: mesh: support sending wide bandwidth CSA
      mac80211: enable VHT for mesh channel processing

Toke Høiland-Jørgensen (1):
      mac80211: Dynamically set CoDel parameters per station

 include/linux/ieee80211.h    |   4 ++
 include/linux/skbuff.h       |   9 +++
 include/net/cfg80211.h       |  42 ++++++++++++++
 include/net/mac80211.h       |  37 ++++++++++--
 include/uapi/linux/nl80211.h |  73 +++++++++++++++++++++--
 net/mac80211/agg-rx.c        |  47 ++++-----------
 net/mac80211/cfg.c           |   1 +
 net/mac80211/debugfs_sta.c   |   6 ++
 net/mac80211/ht.c            |  12 ++++
 net/mac80211/ibss.c          |   1 -
 net/mac80211/ieee80211_i.h   |  16 ++---
 net/mac80211/iface.c         |  25 +-------
 net/mac80211/mesh.c          |  85 ++++++++++++++++++++++++---
 net/mac80211/mesh_plink.c    |   3 +-
 net/mac80211/mlme.c          |   1 -
 net/mac80211/rate.c          |   3 +-
 net/mac80211/rx.c            |   4 --
 net/mac80211/spectmgmt.c     |   7 +++
 net/mac80211/sta_info.c      |  30 ++++++++++
 net/mac80211/sta_info.h      |  14 +++++
 net/mac80211/status.c        |   4 +-
 net/mac80211/trace.h         |  11 ++--
 net/mac80211/tx.c            |   9 ++-
 net/mac80211/util.c          |  37 ++++++++++++
 net/rfkill/rfkill-gpio.c     |   5 +-
 net/wireless/core.c          |   5 ++
 net/wireless/mesh.c          |   8 +++
 net/wireless/nl80211.c       | 135 ++++++++++++++++++++++++++++++++++++++++++-
 net/wireless/rdev-ops.h      |  25 ++++++++
 net/wireless/sme.c           |   1 +
 net/wireless/trace.h         |  60 +++++++++++++++++++
 net/wireless/util.c          |  11 ++--
 32 files changed, 620 insertions(+), 111 deletions(-)
