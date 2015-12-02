From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-12-02
Date: Wed, 02 Dec 2015 22:42:10 +0100
Message-ID: <1449092530.2449.12.camel@sipsolutions.net>
References: <1448552352.2167.14.camel@sipsolutions.net>
	 <1449049610.2449.3.camel@sipsolutions.net>
	 <20151202.154349.931361692047925552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55641 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078AbbLBVmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 16:42:16 -0500
In-Reply-To: <20151202.154349.931361692047925552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Please add them and send a new pull request, I'll just skip over your
> existing one.

Ok, here we go, below a new pull request.

I've added the two commits I spoke about, fixing scanning and an
uninitialized cookie variable that lead to problems if the value
happened to be 0.

Let me know if there's any problem!

Thanks,
johannes


The following changes since commit 17c790a60dad11c0193127e83ac8e183b4fe=
d1a2:

=C2=A0 Merge branch 'mv88e6060-fixes' (2015-11-15 20:16:26 -0500)

are available in the git repository at:

=C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git=
 tags/mac80211-for-davem-2015-12-02

for you to fetch changes up to c1df932c0574c13ab3ce72e969c9647ff3aaad68=
:

=C2=A0 mac80211: fix off-channel mgmt-tx uninitialized variable usage (=
2015-12-02 22:27:53 +0100)

----------------------------------------------------------------
A small set of fixes for 4.4:
=C2=A0* fix scanning in mac80211 to not actively scan radar
=C2=A0=C2=A0=C2=A0channels (from Antonio)
=C2=A0* fix uninitialized variable in remain-on-channel that
=C2=A0=C2=A0=C2=A0could lead to treating frame TX as remain-on-channel
=C2=A0=C2=A0=C2=A0and not sending the frame at all
=C2=A0* remove NL80211_FEATURE_FULL_AP_CLIENT_STATE again, it
=C2=A0=C2=A0=C2=A0was broken and needs more work, we'll enable it later
=C2=A0* fix call_rcu() induced use-after-reset/free in mesh
=C2=A0=C2=A0=C2=A0(that was suddenly causing issues in certain tests)
=C2=A0* always request block-ack window size 64 as we found
=C2=A0=C2=A0=C2=A0some APs will otherwise crash (really ...)
=C2=A0* fix P2P-Device teardown sequence to avoid restarting
=C2=A0=C2=A0=C2=A0with uninitialized data

----------------------------------------------------------------
Antonio Quartulli (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: do not actively scan DFS =
channels

Eliad Peller (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: don't teardown sdata on s=
data stop

Emmanuel Grumbach (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: ensure we don't update tx=
 power on a non-running sdata

Gregory Greenman (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: always set the buf_size i=
n AddBA req to 64

Johannes Berg (3):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: don't advertise NL80211_F=
EATURE_FULL_AP_CLIENT_STATE
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: mesh: fix call_rcu() usag=
e
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: fix off-channel mgmt-tx u=
ninitialized variable usage

=C2=A0include/net/mac80211.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 6 +++=
+--
=C2=A0net/mac80211/agg-tx.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| =
3 ++-
=C2=A0net/mac80211/cfg.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0| 8 ++++++--
=C2=A0net/mac80211/iface.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0| 5 +++--
=C2=A0net/mac80211/main.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0| 3 +--
=C2=A0net/mac80211/mesh_pathtbl.c | 8 ++++----
=C2=A0net/mac80211/scan.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0| 9 +++++----
=C2=A07 files changed, 25 insertions(+), 17 deletions(-)
