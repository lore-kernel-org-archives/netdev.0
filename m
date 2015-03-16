From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-03-16
Date: Mon, 16 Mar 2015 09:43:57 +0100
Message-ID: <1426495437.1935.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48002 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbbCPIoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 04:44:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I meant to send you a pull request last week but then somehow that
slipped through the cracks. However, I've since gotten a number of CSA
(channel switch) related fixes that I've also included - see below.

Let me know if there are any problems.

Thanks,
johannes

The following changes since commit 9c1c98a3bb7b7593b60264b9a07e001e68b46697:

  mac80211: Send EAPOL frames at lowest rate (2015-02-26 21:03:06 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-03-16

for you to fetch changes up to f84eaa1068315409ffbef57e6fea312180787db3:

  mac80211: ignore CSA to same channel (2015-03-16 09:36:12 +0100)

----------------------------------------------------------------
Here are a few fixes that I'd like to still get in:
 * disable U-APSD for better interoperability, from Michal Kazior
 * drop unencrypted frames in mesh forwarding, from Bob Copeland
 * treat non-QoS/WMM HT stations as non-HT, to fix confusion when
   they connect and then get QoS packets anyway due to HT
 * fix counting interfaces for combination checks, otherwise the
   interface combinations aren't properly enforced (from Andrei)
 * fix pure ECSA by reacting to the IE change
 * ignore erroneous (E)CSA to the current channel which sometimes
   happens due to AP/GO bugs

----------------------------------------------------------------
Andrei Otcheretianski (1):
      mac80211: count interfaces correctly for combination checks

Bob Copeland (1):
      mac80211: drop unencrypted frames in mesh fwding

Johannes Berg (3):
      mac80211: ask for ECSA IE to be considered for beacon parse CRC
      nl80211: ignore HT/VHT capabilities without QoS/WMM
      mac80211: ignore CSA to same channel

Michal Kazior (1):
      mac80211: disable u-APSD queues by default

 net/mac80211/ieee80211_i.h | 24 ++++++++++++++++++------
 net/mac80211/mlme.c        | 16 +++++++++++++++-
 net/mac80211/rx.c          |  3 +++
 net/mac80211/util.c        |  2 +-
 net/wireless/nl80211.c     | 10 ++++++++++
 5 files changed, 47 insertions(+), 8 deletions(-)
