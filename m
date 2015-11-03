From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-11-03
Date: Tue, 03 Nov 2015 15:40:02 +0100
Message-ID: <1446561602.29010.23.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56843 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370AbbKCOkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 09:40:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After the travel I got a whole bunch of things in - I've sorted through
and taken the fix-like things.

Note that this is in the mac80211 tree, but based on net-next, since I
thought you might decide to pull this in before you send a pull request
to Linus.
However, the content is only things I'd also send after -rc1 (with the
WMM stuff being a bit borderline, since it's fairly big, but it's a
huge improvement with broken APs and we've had it in our Intel tree
testing there for quite a while.)

Let me know if you run into any problems.

johannes



The following changes since commit e9829b9745b6e1683fd2a90842da498a2197299e:

  Merge tag 'mac80211-next-for-davem-2015-10-21' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next (2015-10-22 07:28:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-11-03

for you to fetch changes up to e4208427247ecc7306c8f71ab3c5c08e08cf9fda:

  cfg80211: allow AID/listen interval changes for unassociated station (2015-11-03 11:20:29 +0100)

----------------------------------------------------------------
Another set of fixes:
 * remove a warning on a check that can trigger without any
   errors having happened (Andrei)
 * correctly handle deauth request while in the process of
   associating (Andrei)
 * fix TDLS HT operation (Arik)
 * allow changing AID/listen interval during client setup (Ayala)
 * be more forgiving with WMM parameters to get HT/VHT in case of
   broken APs with bad WMM settings (Emmanuel, myself)
 * a number of other fixes (some in documentation)

----------------------------------------------------------------
Andrei Otcheretianski (2):
      mac80211: Fix local deauth while associating
      mac80211: Remove WARN_ON_ONCE in ieee80211_recalc_smps

Arik Nemtsov (2):
      mac80211: allow null chandef in tracing
      mac80211: TDLS: add proper HT-oper IE

Ayala Beker (1):
      cfg80211: allow AID/listen interval changes for unassociated station

Chaitanya T K (1):
      mac80211: document sleep requirements for channel context ops

Eliad Peller (3):
      mac80211: use freezable workqueue for restart work
      mac80211: call drv_stop only if driver is started
      mac80211: don't reconfigure sched scan in case of wowlan

Emmanuel Grumbach (1):
      mac80211: fixup AIFSN instead of disabling WMM

Janusz.Dziedzic@tieto.com (1):
      mac80211: fix divide by zero when NOA update

Johannes Berg (4):
      cfg80211/mac80211: clarify RSSI CQM reporting requirements
      mac80211: make enable_qos parameter to ieee80211_set_wmm_default()
      mac80211: treat bad WMM parameters more gracefully
      mac80211: further improve "no supported rates" warning

Matthias Schiffer (1):
      mac80211: fix crash on mesh local link ID generation with VIFs

Ola Olsson (1):
      nl80211: Fix potential memory leak from parse_acl_data

 include/net/cfg80211.h     |   4 ++
 include/net/mac80211.h     |  10 ++-
 net/mac80211/cfg.c         |   6 +-
 net/mac80211/driver-ops.c  |  46 ++++++++++++
 net/mac80211/driver-ops.h  |  42 ++++-------
 net/mac80211/ibss.c        |   4 +-
 net/mac80211/ieee80211_i.h |   6 +-
 net/mac80211/iface.c       |   8 ++-
 net/mac80211/main.c        |   2 +-
 net/mac80211/mesh.c        |   3 +-
 net/mac80211/mesh_plink.c  |   3 +
 net/mac80211/mlme.c        | 173 +++++++++++++++++++--------------------------
 net/mac80211/pm.c          |  11 +++
 net/mac80211/rate.c        |   2 +-
 net/mac80211/scan.c        |  12 ++--
 net/mac80211/tdls.c        |  13 +++-
 net/mac80211/trace.h       |  10 +--
 net/mac80211/util.c        |  94 ++++++++++++++----------
 net/wireless/nl80211.c     |  39 ++++++----
 19 files changed, 277 insertions(+), 211 deletions(-)
