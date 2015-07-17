From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-07-17
Date: Fri, 17 Jul 2015 15:31:34 +0200
Message-ID: <1437139894.1933.16.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52890 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757488AbbGQNbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 09:31:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

We've accumulated some wireless fixes, please pull. Arik's fix is a bit
bigger than I might like, but it fixes a real locking issue and we
didn't really see a good way to make a smaller version.

Let me know if there's any problem.

johannes


The following changes since commit f760b87f8f12eb262f14603e65042996fe03720e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-07-13 11:18:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-07-17

for you to fetch changes up to 923b352f19d9ea971ae2536eab55f5fc9e95fedf:

  cfg80211: use RTNL locked reg_can_beacon for IR-relaxation (2015-07-17 15:02:02 +0200)

----------------------------------------------------------------
Some fixes for the current cycle:

 1. Arik introduced an rtnl-locked regulatory API to be able
    to differentiate between place do/don't have the RTNL;
    this fixes missing locking in some of the code paths

 2. Two small mesh bugfixes from Bob, one to avoid treating
    a certain malformed over-the-air frame and one to avoid
    sending a garbage field over the air.

 3. A fix for powersave during WoWLAN suspend from Krishna Chaitanya.

 4. A fix for a powersave vs. aggregation teardown race, from Michal.

 5. Thomas reduced the loglevel of CRDA messages to avoid spamming
    the kernel log with mostly irrelevant information.

 6. Tom fixed a dangling debugfs directory pointer that could cause
    crashes if subsequent addition of the same interface to debugfs
    failed for some reason.

 7. A fix from myself for a list corruption issue in mac80211 during
    combined interface shutdown/removal - shut down interfaces first
    and only then remove them to avoid that.

----------------------------------------------------------------
Arik Nemtsov (1):
      cfg80211: use RTNL locked reg_can_beacon for IR-relaxation

Bob Copeland (2):
      mac80211: correct aid location in peering frames
      mac80211: add missing length check for confirm frames

Chaitanya T K (1):
      mac80211: wowlan: enable powersave if suspend while ps-polling

Johannes Berg (1):
      mac80211: shut down interfaces before destroying interface list

Michal Kazior (1):
      mac80211: don't clear all tx flags when requeing

Thomas Petazzoni (1):
      wireless: regulatory: reduce log level of CRDA related messages

Tom Hughes (1):
      mac80211: clear subdir_stations when removing debugfs

 include/net/cfg80211.h        | 17 ++++++++++++++++
 net/mac80211/debugfs_netdev.c |  1 +
 net/mac80211/iface.c          | 25 +++++++++++++-----------
 net/mac80211/mesh_plink.c     |  5 ++++-
 net/mac80211/pm.c             | 16 +++++++++++++++
 net/mac80211/tdls.c           |  6 +++---
 net/mac80211/tx.c             |  4 +++-
 net/wireless/chan.c           | 45 ++++++++++++++++++++++++++++++++-----------
 net/wireless/nl80211.c        | 14 ++++++++------
 net/wireless/reg.c            |  8 ++++----
 net/wireless/trace.h          | 11 +++++++----
 11 files changed, 111 insertions(+), 41 deletions(-)
