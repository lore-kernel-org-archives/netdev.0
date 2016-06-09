From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2016-06-09
Date: Thu,  9 Jun 2016 15:04:25 +0200
Message-ID: <1465477466-23756-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59711 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbcFINEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 09:04:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's my first set of changes for -next. The only exciting part are th=
e
changes from Micha=C5=82 to integrate FQ/codel into mac80211's software=
 queues
to improve cross-station latency and finally solve much of the latency
issues so many people have spent so much time talking about, but never
actually working on fixing until he did :)

Can I ask you to pull net into net-next, preferably before merging this=
?
I have a patch that is unsafe without a fix that I submitted through
mac80211 previously (last time, not the pull request a few minutes ago)=
,
and I'd prefer not to have that in our -next trees without the fix. If
you merge net into net-next before this pull request I can fast-forward
mac80211-next to this merge later.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 07b75260ebc2c789724c594d7eaf0194fa47=
b3be:

  Merge branch 'upstream' of git://git.linux-mips.org/pub/scm/ralf/upst=
ream-linus (2016-05-19 10:02:26 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git=
 tags/mac80211-next-for-davem-2016-06-09

for you to fetch changes up to 5caa328e3811b7cfa33fd02c93280ffa622deb0e=
:

  mac80211: implement codel on fair queuing flows (2016-06-09 11:45:10 =
+0200)

----------------------------------------------------------------
=46or the next cycle, we have the following:
 * the biggest change is Micha=C5=82's work on integrating FQ/codel
   with the mac80211 internal software queues
 * cfg80211 connect result gets clarified for the
   "no connection at all" case
 * advertisement of per-interface type capabilities, in case
   they differ (which makes a lot of sense for some capabilities)
 * most of the nl80211 & hwsim unprivileged namespace operation
   changes
 * human-readable VHT capabilities in debugfs
 * some other cleanups, like spelling

----------------------------------------------------------------
Ben Greear (1):
      mac80211: add vht cap decode to debugfs

Johannes Berg (2):
      wext: reformat struct/union declarations
      nl80211: clarify nl80211_set_reg() success path

Jouni Malinen (1):
      cfg80211: Allow cfg80211_connect_result() errors to be distinguis=
hed

Kanchanapally, Vidyullatha (1):
      cfg80211: Advertise extended capabilities per interface type to u=
serspace

Kirtika Ruchandani (2):
      nl80211: Fix spelling
      nl80211: Fix checkpatch warnings about blank lines

Martin Willi (2):
      nl80211: Allow privileged operations from user namespaces
      mac80211_hwsim: Allow managing radios from non-initial namespaces

Michal Kazior (4):
      mac80211: skip netdev queue control with software queuing
      mac80211: implement fair queueing per txq
      mac80211: add debug knobs for fair queuing
      mac80211: implement codel on fair queuing flows

 Documentation/DocBook/80211.tmpl      |   1 +
 drivers/net/wireless/mac80211_hwsim.c |  97 ++++++++++-
 include/net/cfg80211.h                |  81 ++++++++--
 include/net/mac80211.h                |  18 ++-
 include/uapi/linux/nl80211.h          |  14 +-
 include/uapi/linux/wireless.h         |  63 +++-----
 net/mac80211/agg-tx.c                 |   8 +-
 net/mac80211/debugfs.c                | 173 ++++++++++++++++++++
 net/mac80211/debugfs_sta.c            |  78 ++++++++-
 net/mac80211/ieee80211_i.h            |  31 +++-
 net/mac80211/iface.c                  |  26 ++-
 net/mac80211/main.c                   |  10 +-
 net/mac80211/rx.c                     |   2 +-
 net/mac80211/sta_info.c               |  14 +-
 net/mac80211/tx.c                     | 292 ++++++++++++++++++++++++++=
+++-----
 net/mac80211/util.c                   |  34 +---
 net/wireless/core.c                   |  30 ++++
 net/wireless/core.h                   |   4 +-
 net/wireless/nl80211.c                | 232 ++++++++++++++++----------=
-
 net/wireless/nl80211.h                |   2 +-
 net/wireless/sme.c                    |   8 +-
 21 files changed, 955 insertions(+), 263 deletions(-)
