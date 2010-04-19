From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 19 Apr 2010 00:38:57 -0700 (PDT)
Message-ID: <20100419.003857.260094283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix TX lockups in forcedeth due to an incorrect chipset ID check
   wrt. whether to enable a TX hw bug workaround or not.  Fix from
   Ayaz Abdulla.

2) Fix some virtualization problems by orphan'ing the SKB on TX
   in tun driver.  From Michael S. Tsirkin.

3) Some minor fallout from the slab.h cleanups in gigaset driver,
   from Tilman Schmidt.

4) hdlc_ppp can crash on rmmod due to lack of PPP tx queue flush,
   fix from Krzysztof Halasa.

5) Three fixes from Eric Dumazet:
   a) ip_dev_loopback_xmit() needs to use netif_rx_ni() since it sometimes
      is invoked from user context and therefore an explicit check and
      run of softirqs is necessary.
   b) dev_pic_tx() should not cache a socket TX queue selection unless
      the socket cache'd dst matches the one currently hung off of the
      skb
   c) Fix lockdep false positives in fib_trie

6) AF_PACKET erroneously restricts to init_net in some ioctls, fix
   from Daniel Lezcano.

7) iwlwifi active chain detection fix from Johannes Berg.

Please pull, thanks a lot!

The following changes since commit 13bd8e4673d527a9e48f41956b11d391e7c2cfe0:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../anholt/drm-intel

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ayaz Abdulla (1):
      forcedeth: fix tx limit2 flag check

Daniel Lezcano (1):
      packet : remove init_net restriction

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Eric Dumazet (3):
      fib: suppress lockdep-RCU false positive in FIB trie.
      net: dev_pick_tx() fix
      ip: Fix ip_dev_loopback_xmit()

Johannes Berg (1):
      iwlwifi: work around bogus active chains detection

Krzysztof Halasa (1):
      WAN: flush tx_queue in hdlc_ppp to prevent panic on rmmod hw_driver.

Michael S. Tsirkin (1):
      tun: orphan an skb on tx

Tilman Schmidt (1):
      gigaset: include cleanup cleanup

 drivers/isdn/gigaset/bas-gigaset.c       |    5 -----
 drivers/isdn/gigaset/capi.c              |    2 --
 drivers/isdn/gigaset/common.c            |    2 --
 drivers/isdn/gigaset/gigaset.h           |    2 +-
 drivers/isdn/gigaset/i4l.c               |    1 -
 drivers/isdn/gigaset/interface.c         |    1 -
 drivers/isdn/gigaset/proc.c              |    1 -
 drivers/isdn/gigaset/ser-gigaset.c       |    3 ---
 drivers/isdn/gigaset/usb-gigaset.c       |    4 ----
 drivers/net/forcedeth.c                  |    2 +-
 drivers/net/tun.c                        |    4 ++++
 drivers/net/wan/hdlc_ppp.c               |    6 ++++++
 drivers/net/wireless/iwlwifi/iwl-calib.c |   12 ++++++++++++
 net/core/dev.c                           |    8 ++++++--
 net/ipv4/fib_trie.c                      |    4 +++-
 net/ipv4/ip_output.c                     |    2 +-
 net/ipv6/ip6_output.c                    |    2 +-
 net/packet/af_packet.c                   |    2 --
 18 files changed, 35 insertions(+), 28 deletions(-)
