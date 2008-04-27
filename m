From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking fixes
Date: Sun, 27 Apr 2008 16:56:55 -0700 (PDT)
Message-ID: <20080427.165655.96444093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750885AbYD0X4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 19:56:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) TIPC and ipv6 endianness cures from Al Viro.

2) Fix copy_from_user() results being used as error returns,
   from Sam Ravnborg, based upon a patch from Pavel E.

3) When asking for null authentication algorithm in ESP, we get a null
   hmac, instead of just a plain null digest.  Fix from Herbert Xu.

4) Missing SunRPC kernel-doc annotation from Randy Dunlap.

5) IPSEC auditing prints out the flowlabel incorrectly.  Fix from
   Yoshifuji HIDEAKI.

6) Compat 32-bit support for multicast socket options was missing,
   fix from David L. Stevens.

7) Hopefully, the final build fixes necessary for the iwlwifi driver.
   A lot of this stems from some areas of Kconfig that could be
   improved and I'll start a thread about that.

Please pull, thanks a lot!

The following changes since commit 653252c2302cdf2dfbca66a7e177f7db783f9efa:
  Pavel Emelyanov (1):
        net: Fix wrong interpretation of some copy_to_user() results.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Al Viro (2):
      ipv6: result of csum_fold() is already 16bit, no need to cast
      tipc: endianness annotations

David L Stevens (1):
      ipv4/ipv6 compat: Fix SSM applications on 64bit kernels.

David S. Miller (1):
      Revert "ipv6: Fix typo in net/ipv6/Kconfig"

Evgeniy Polyakov (1):
      tcp: Fix slab corruption with ipv6 and tcp6fuzz

Herbert Xu (1):
      [IPSEC]: Use digest_null directly for auth

Jason Riedy (1):
      iwlwifi: Allow building iwl3945 without iwl4965.

Luca Tettamanti (1):
      wireless: Fix compile error with wifi & leds

Randy Dunlap (1):
      sunrpc: fix missing kernel-doc

Sam Ravnborg (1):
      can: Fix copy_from_user() results interpretation

YOSHIFUJI Hideaki (1):
      [XFRM] AUDIT: Fix flowlabel text format ambibuity.

 drivers/net/wireless/Makefile        |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig |    6 ++
 include/net/compat.h                 |    3 +
 net/can/raw.c                        |   21 +++---
 net/compat.c                         |  117 ++++++++++++++++++++++++++++++++++
 net/ipv4/ip_sockglue.c               |    5 ++
 net/ipv4/tcp_input.c                 |    3 +-
 net/ipv6/Kconfig                     |    2 +-
 net/ipv6/ip6mr.c                     |    2 +-
 net/ipv6/ipv6_sockglue.c             |    5 ++
 net/mac80211/Kconfig                 |    4 +-
 net/sunrpc/xprt.c                    |    2 +-
 net/tipc/msg.h                       |    7 +-
 net/xfrm/xfrm_algo.c                 |    3 +-
 net/xfrm/xfrm_state.c                |    2 +-
 15 files changed, 159 insertions(+), 25 deletions(-)
