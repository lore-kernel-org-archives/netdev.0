From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2015-02-03
Date: Tue, 03 Feb 2015 14:51:43 +0100
Message-ID: <1422971503.2237.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Here's a last pull request for net-next - I hope it can still make it,
we fixed a fairly large number of issues. Also there's a bunch of new
ciphers, but see the details below.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit c1e140bf79d817d4a7aa9932eb98b0359c87af33:

  mac80211: delete the assoc/auth timer upon suspend (2015-01-19 18:59:20 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-02-03

for you to fetch changes up to 79044f60caa7c377333dc8f13cf1e48c144e2521:

  net: rfkill: Add Broadcom BCM2E40 bluetooth ACPI ID (2015-02-03 14:38:22 +0100)

----------------------------------------------------------------
Last round of updates for net-next:
 * revert a patch that caused a regression with mesh userspace (Bob)
 * fix a number of suspend/resume related races
   (from Emmanuel, Luca and myself - we'll look at backporting later)
 * add software implementations for new ciphers (Jouni)
 * add a new ACPI ID for Broadcom's rfkill (Mika)
 * allow using netns FD for wireless (Vadim)
 * some other cleanups (various)

----------------------------------------------------------------
Bob Copeland (1):
      Revert "mac80211: keep sending peer candidate events while in listen state"

Emmanuel Grumbach (2):
      mac80211: synchronize_net() before flushing the queues
      mac80211: avoid races related to suspend flow

Johannes Berg (9):
      mac80211: fix HW registration error paths
      mac80211: allow drivers to control software crypto
      nl80211: suppress smatch warnings
      mac80211: tdls: remove shadowing variable
      mac80211: tdls: disentangle HT supported conditions
      mac80211: fix per-TID RX-MSDU counter
      mac80211: support beacon statistics
      ath10k: use IEEE80211_HW_SW_CRYPTO_CONTROL
      nl80211: don't document per-wiphy interface dump

Jouni Malinen (6):
      cfg80211: Fix BIP (AES-CMAC) cipher validation
      cfg80211: Add new GCMP, CCMP-256, BIP-GMAC, BIP-CMAC-256 ciphers
      mac80111: Add GCMP and GCMP-256 ciphers
      mac80111: Add CCMP-256 cipher
      mac80111: Add BIP-CMAC-256 cipher
      mac80111: Add BIP-GMAC-128 and BIP-GMAC-256 ciphers

Lorenzo Bianconi (1):
      mac80211: enable TPC through mac80211 stack

Luciano Coelho (3):
      nl80211: add an attribute to allow delaying the first scheduled scan cycle
      mac80211: complete scan work immediately if quiesced or suspended
      mac80211: handle potential race between suspend and scan completion

Mika Westerberg (1):
      net: rfkill: Add Broadcom BCM2E40 bluetooth ACPI ID

Sharon Dvir (1):
      wireless: docs: fix 'make pdfdocs' failure

Vadim Kochan (1):
      nl80211: Allow set network namespace by fd

 Documentation/DocBook/80211.tmpl      |   4 +-
 drivers/net/wireless/ath/ath10k/mac.c |  16 +-
 include/linux/ieee80211.h             |  27 +++
 include/net/cfg80211.h                |   5 +
 include/net/mac80211.h                |  39 ++-
 include/uapi/linux/nl80211.h          |  26 +-
 net/core/net_namespace.c              |   1 +
 net/mac80211/Kconfig                  |   1 +
 net/mac80211/Makefile                 |   2 +
 net/mac80211/aes_ccm.c                |  21 +-
 net/mac80211/aes_ccm.h                |  10 +-
 net/mac80211/aes_cmac.c               |  34 ++-
 net/mac80211/aes_cmac.h               |   5 +-
 net/mac80211/aes_gcm.c                |  95 ++++++++
 net/mac80211/aes_gcm.h                |  22 ++
 net/mac80211/aes_gmac.c               |  84 +++++++
 net/mac80211/aes_gmac.h               |  20 ++
 net/mac80211/cfg.c                    |  50 +++-
 net/mac80211/chan.c                   |   4 +-
 net/mac80211/debugfs_key.c            |  55 +++++
 net/mac80211/ieee80211_i.h            |  36 ++-
 net/mac80211/iface.c                  |  12 +-
 net/mac80211/key.c                    | 185 +++++++++++++-
 net/mac80211/key.h                    |  18 ++
 net/mac80211/main.c                   | 107 +++++---
 net/mac80211/mesh_plink.c             |   7 -
 net/mac80211/mlme.c                   |   3 +
 net/mac80211/rx.c                     |  48 +++-
 net/mac80211/scan.c                   |   5 +
 net/mac80211/sta_info.c               |  14 ++
 net/mac80211/tdls.c                   |  37 ++-
 net/mac80211/tx.c                     |  20 +-
 net/mac80211/util.c                   |  27 ++-
 net/mac80211/wpa.c                    | 443 +++++++++++++++++++++++++++++++++-
 net/mac80211/wpa.h                    |  19 +-
 net/rfkill/rfkill-gpio.c              |   1 +
 net/wireless/nl80211.c                |  31 ++-
 net/wireless/util.c                   |  68 +++++-
 38 files changed, 1426 insertions(+), 176 deletions(-)
 create mode 100644 net/mac80211/aes_gcm.c
 create mode 100644 net/mac80211/aes_gcm.h
 create mode 100644 net/mac80211/aes_gmac.c
 create mode 100644 net/mac80211/aes_gmac.h


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
