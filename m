From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 16 Feb 2010 16:46:10 -0800 (PST)
Message-ID: <20100216.164610.264043146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) When TCP timestamps are disabled, we can end up with an
   ->srtt of zero after the three way handshake, and if the
   right series of losses occur afterwards we end up in an
   ACK war.  Fix from Damian Lukowski.

2) Fix 1G flow control and WOL setup in IXGBE driver, from Don	
   Skidmore.

3) Type in SSB layer causes SDIOHOST case to not hookup parent
   bus/device pointers properly.  Fix from Michael Buesch.

4) Fix locking regressions wrt. ->poll() and changing IRQ coalesce
   settings in VIA Velocity driver.  From Simon Kagstrom.

5) Looking at the GRO setting by normal users is restricted
   unnecessarily.  From Stephen Hemminger.

6) Couple of wireless stragglers including a B43 throughput
   regression fix from Larry Finger.

7) We pretend to handle IGMPv3 reports, but really the structure
   is different so such handling is wrong.  Fix from Herbert Xu.

8) be2net driver fix to properly initialize the version field to
   zero in request headers.  From Ajit Khaparde.

9) IPCOMP can double release an object on errors, from Herbert Xu.

10) If an error happens when cloning an XFRM state we'll leak
    the module reference because we directly kfree() instead of
    doing a put on the object.  Also from Herbert Xu.

Please pull, thanks a lot!

The following changes since commit 88626272549b94310975932a9970d11a9b362a16:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../agk/linux-2.6-dm

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: set proper value to version field in req hdr

Benoit Papillault (1):
      mac80211: Fix probe request filtering in IBSS mode

Damian Lukowski (1):
      tcp: fix ICMP-RTO war

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of ssh://master.kernel.org/.../linville/wireless-2.6

Don Skidmore (2):
      ixgbe: Fix - Do not allow Rx FC on 82598 at 1G due to errata
      ixgbe: fix WOL register setup for 82599

Herbert Xu (3):
      inet: Remove bogus IGMPv3 report handling
      ipcomp: Avoid duplicate calls to ipcomp_destroy
      xfrm: Fix xfrm_state_clone leak

Jelle Martijn Kok (1):
      rtl8187: Add new device ID

Johannes Berg (1):
      mac80211: fix deferred hardware scan requests

Juuso Oikarinen (1):
      mac80211: fix handling of null-rate control in rate_control_get_rate

Larry Finger (1):
      b43: Fix throughput regression

Michael Buesch (1):
      ssb: Fix CONFIG_SSB_SDIOHOST typo

Roel Kluin (1):
      iwmc3200wifi: Test of wrong pointer after kzalloc in iwm_mlme_update_bss_table()

Shanyu Zhao (1):
      iwlwifi: fix AMSDU Rx after paged Rx patch

Simon Kagstrom (3):
      via-velocity: Remove unused IRQ status parameter from rx_srv and tx_srv
      via-velocity: Take spinlock on set coalesce
      via-velocity: Fix races on shared interrupts

Steve Hodgson (1):
      sfc: Fix SFE4002 initialisation

Sujith (1):
      ath9k: Fix sequence numbers for PAE frames

Wey-Yi Guy (1):
      iwlwifi: Fix to set correct ht configuration

stephen hemminger (1):
      ethtool: allow non-admin user to read GRO settings.

 drivers/net/benet/be_cmds.c                |    1 +
 drivers/net/ixgbe/ixgbe_82598.c            |   22 +++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c             |    4 +++
 drivers/net/sfc/efx.c                      |    1 +
 drivers/net/sfc/qt202x_phy.c               |    2 +-
 drivers/net/via-velocity.c                 |   41 +++++++++++++--------------
 drivers/net/wireless/ath/ath9k/xmit.c      |    4 +-
 drivers/net/wireless/b43/b43.h             |    1 +
 drivers/net/wireless/b43/main.c            |   13 +++++++--
 drivers/net/wireless/iwlwifi/iwl-core.c    |    1 +
 drivers/net/wireless/iwlwifi/iwl-rx.c      |    5 +++-
 drivers/net/wireless/iwmc3200wifi/rx.c     |    2 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c |    1 +
 drivers/ssb/main.c                         |    3 +-
 net/core/ethtool.c                         |    1 +
 net/ipv4/igmp.c                            |    2 +-
 net/ipv4/ipcomp.c                          |    6 +---
 net/ipv4/tcp_input.c                       |    6 +---
 net/ipv6/ipcomp6.c                         |    6 +---
 net/mac80211/ibss.c                        |    2 +-
 net/mac80211/rate.c                        |    3 ++
 net/mac80211/scan.c                        |   18 +++++++-----
 net/xfrm/xfrm_state.c                      |   12 ++------
 23 files changed, 93 insertions(+), 64 deletions(-)
