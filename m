From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2016-10-04
Date: Tue,  4 Oct 2016 09:31:28 +0200
Message-ID: <1475567338-28291-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40173 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932220AbcJDHtE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 03:49:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's a version with the conflicts resolved - had to jigger some
code around, but it's all described in the merge commit message.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 9a8dd213d2a38349e5ea2ca8888400952112b45c:

  Merge branch 'ncsi-next' (2016-10-04 02:11:58 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2016-10-04

for you to fetch changes up to 1e1430d5282bc3a572465ef3261eea793d98a653:

  Merge remote-tracking branch 'net-next/master' into mac80211-next (2016-10-04 09:46:44 +0200)

----------------------------------------------------------------
This time around, we have
 * Neighbor Awareness Networking (NAN) APIs
 * a fix for a previous patch that caused memory corruption
   in wireless extensions key settings
 * beacon rate configuration for AP and mesh
 * memory limits for mac80211's internal TXQs
 * a (fairly involved) fix for the TXQ vs. crypto problems
 * direct cfg80211 driver API for WEP keys

This also pulls in net-next to fix the merge conflicts, see
the merge commit for more details.

----------------------------------------------------------------
Ayala Beker (9):
      cfg80211: add start / stop NAN commands
      mac80211: add boilerplate code for start / stop NAN
      cfg80211: add add_nan_func / del_nan_func
      cfg80211: allow the user space to change current NAN configuration
      cfg80211: provide a function to report a match for NAN
      cfg80211: Provide an API to report NAN function termination
      mac80211: implement nan_change_conf
      mac80211: Implement add_nan_func and rm_nan_func
      mac80211: Add API to report NAN function match

David Spinadel (1):
      cfg80211: Add support for static WEP in the driver

Johannes Berg (3):
      cfg80211: add checks for beacon rate, extend to mesh
      cfg80211: wext: really don't store non-WEP keys
      Merge remote-tracking branch 'net-next/master' into mac80211-next

Pedersen, Thomas (2):
      mac80211: add offset_tsf driver op and use it for mesh
      mac80211: mesh: decrease max drift

Purushottam Kushwaha (1):
      cfg80211: Add support to configure a beacon data rate

Toke Høiland-Jørgensen (5):
      mac80211: Move ieee802111_tx_dequeue() to later in tx.c
      fq.h: Port memory limit mechanism from fq_codel
      mac80211: Export fq memory limit information in debugfs
      mac80211: Set lower memory limit for non-VHT devices
      mac80211: Move reorder-sensitive TX handlers to after TXQ dequeue

 include/net/cfg80211.h        |  223 +++++++-
 include/net/fq.h              |    3 +
 include/net/fq_impl.h         |    7 +-
 include/net/mac80211.h        |   75 +++
 include/uapi/linux/nl80211.h  |  270 ++++++++-
 net/mac80211/cfg.c            |  208 +++++++
 net/mac80211/chan.c           |    6 +
 net/mac80211/debugfs.c        |    8 +
 net/mac80211/debugfs_netdev.c |   12 +-
 net/mac80211/driver-ops.c     |   15 +
 net/mac80211/driver-ops.h     |   83 +++
 net/mac80211/ieee80211_i.h    |   26 +
 net/mac80211/iface.c          |   28 +-
 net/mac80211/main.c           |    8 +
 net/mac80211/mesh_sync.c      |   12 +-
 net/mac80211/offchannel.c     |    4 +-
 net/mac80211/rx.c             |    7 +-
 net/mac80211/sta_info.c       |   10 +-
 net/mac80211/trace.h          |  159 ++++++
 net/mac80211/tx.c             |  420 +++++++++-----
 net/mac80211/util.c           |   61 ++-
 net/wireless/chan.c           |    2 +
 net/wireless/core.c           |   35 ++
 net/wireless/core.h           |    7 +-
 net/wireless/ibss.c           |    5 +-
 net/wireless/mlme.c           |    1 +
 net/wireless/nl80211.c        | 1220 ++++++++++++++++++++++++++++++++---------
 net/wireless/rdev-ops.h       |   58 ++
 net/wireless/sme.c            |    6 +-
 net/wireless/trace.h          |   90 +++
 net/wireless/util.c           |   30 +-
 net/wireless/wext-compat.c    |   14 +-
 net/wireless/wext-sme.c       |    2 +-
 33 files changed, 2682 insertions(+), 433 deletions(-)
