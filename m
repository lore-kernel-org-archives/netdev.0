From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-12-15
Date: Tue, 15 Dec 2015 13:30:21 +0100
Message-ID: <1450182621.3356.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

After going through my patch queue, I have another set of fixes that I
think is still appropriate for the current cycle.

Two of my own restart changes there are fairly big but for the most
part just move code around so it can be called in a slightly different
order.

Let me know if there are any issues.

Thanks,
johannes


The following changes since commit c1df932c0574c13ab3ce72e969c9647ff3aa=
ad68:

=C2=A0 mac80211: fix off-channel mgmt-tx uninitialized variable usage (=
2015-12-02 22:27:53 +0100)

are available in the git repository at:

=C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git=
 tags/mac80211-for-davem-2015-12-15

for you to fetch changes up to cf1e05c63642ce65821a6277adfc2157f7334c9d=
:

=C2=A0 mac80211: handle width changes from opmode notification IE in be=
acon (2015-12-15 13:16:47 +0100)

----------------------------------------------------------------
Another set of fixes:
=C2=A0* memory leak fixes (from Ola)
=C2=A0* operating mode notification spec compliance fix (from Eyal)
=C2=A0* copy rfkill names in case pointer becomes invalid (myself)
=C2=A0* two hardware restart fixes (myself)
=C2=A0* get rid of "limiting TX power" log spam (myself)

----------------------------------------------------------------
Eyal Shapira (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: handle width changes from=
 opmode notification IE in beacon

Johannes Berg (4):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rfkill: copy the name into the rfki=
ll struct
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: run scan completed work o=
n reconfig failure
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: reprogram in interface or=
der
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: suppress unchanged "limit=
ing TX power" messages

Ola Olsson (3):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0nl80211: fix a few memory leaks in =
reg.c
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0nl80211: Fix potential memory leak =
in nl80211_set_wowlan
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0nl80211: Fix potential memory leak =
in nl80211_connect

=C2=A0net/mac80211/cfg.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0|=C2=A0=C2=A0=C2=A03 +-
=C2=A0net/mac80211/ieee80211_i.h |=C2=A0=C2=A0=C2=A04 +-
=C2=A0net/mac80211/mlme.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
|=C2=A0=C2=A017 ++++---
=C2=A0net/mac80211/rx.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A03 +-
=C2=A0net/mac80211/util.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
| 113 +++++++++++++++++++++++++--------------------
=C2=A0net/mac80211/vht.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0|=C2=A0=C2=A010 ++--
=C2=A0net/rfkill/core.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A06 +--
=C2=A0net/wireless/nl80211.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=
=C2=A05 +-
=C2=A0net/wireless/reg.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0|=C2=A0=C2=A0=C2=A05 +-
=C2=A09 files changed, 92 insertions(+), 74 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
