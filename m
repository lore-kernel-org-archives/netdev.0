From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 23 Apr 2008 05:53:43 -0700 (PDT)
Message-ID: <20080423.055343.129838806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752523AbYDWMxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 08:53:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This has cures for several build failures, including the one you
reported yesterday with the iwlwifi driver Linus:

1) Fix iwlcore.o link, fix from Tomas Winkler.

2) iwlwifi and rt2x00 build can break because they use depends on
   LEDS_CLASS instead of select, remove bogus HAS_IOMEM guard to
   NEW_LEDS to facilitate that.

3) rose_node_list_lock is taken when it isn't even needed, resulting
   in lockups, fix by Bernard Pidoux.

4) If we expose the network device "dev_id", things like udev
   can use it to distinguish unique network devices that are
   otherwise indistinguishable.

5) Fix issue with enabling crypto algorithms with IDs > 31 in
   IPSEC, from Herbert Xu.

6) Network namespace race bug fixes for ipv6, and some minor cleanups
   by Pavel Emelyanov.

7) Kernel doc fix for struct sk_buff from Randy Dunlap.

8) TCP comment typo fix from Satoru SATOH.

9) IPV4 and DCCP call do_gettimeofday() then do conversions back,
   which are silly, these things can just call getnstimeofday()
   directly and avoid all of that fuss.  From YOSHIFUJI Hideaki.

10) TCP has open-coded test equivalen to before() macro, use it.
    From Arnd Hannemann.

11) The Solaris/SunOS syscall support removal changeset allows
    several networking exports to be removed, from Adrian Bunk.

Please pull, thanks a lot!

The following changes since commit 43837b1e6c5aef803d57009a68db18df13e64892:
  Bernard Pidoux (1):
        rose: Socket lock was not released before returning to user space

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (3):
      [IPV6]: Make struct ip6_prohibit_entry_template static.
      [IPV4]: Make icmp_sk_init() static.
      net: Unexport move_addr_to_{kernel,user}

Arnd Hannemann (1):
      tcp: Make use of before macro in tcp_input.c

Bernard Pidoux (1):
      [ROSE]: Fix soft lockup wrt. rose_node_list_lock

David S. Miller (3):
      leds: Do not guard NEW_LEDS with HAS_IOMEM
      iwlwifi: Select LEDS_CLASS.
      rt2x00: Select LEDS_CLASS.

David Woodhouse (1):
      [NET]: Expose netdevice dev_id through sysfs

Herbert Xu (1):
      [IPSEC]: Fix catch-22 with algorithm IDs above 31

Mark Asselstine (1):
      hamradio: Remove unneeded and deprecated cli()/sti() calls in dmascc.c

Pavel Emelyanov (3):
      [NETNS]: The ip6_fib_timer can work with garbage on net namespace stop.
      [NETNS]: Don't initialize err variable twice.
      [NETNS]: Remove empty ->init callback.

Randy Dunlap (1):
      skbuff: fix missing kernel-doc notation

Satoru SATOH (1):
      tcp: Trivial fix to correct function name in a comment in net/ipv4/tcp.c

Tomas Winkler (1):
      iwlwifi: Fix built-in compilation of iwlcore

YOSHIFUJI Hideaki (3):
      [IPV4]: Convert do_gettimeofday() to getnstimeofday().
      [DCCP]: Convert do_gettimeofday() to getnstimeofday().
      time: Export set_normalized_timespec.

 drivers/leds/Kconfig                  |    1 -
 drivers/net/hamradio/dmascc.c         |    3 ---
 drivers/net/wireless/iwlwifi/Kconfig  |    8 ++++++--
 drivers/net/wireless/iwlwifi/Makefile |    2 +-
 drivers/net/wireless/rt2x00/Kconfig   |   15 ++++++++++-----
 include/linux/skbuff.h                |    1 +
 include/net/xfrm.h                    |    3 +++
 kernel/time.c                         |    1 +
 net/core/net-sysfs.c                  |    2 ++
 net/dccp/probe.c                      |   17 ++++++-----------
 net/ipv4/icmp.c                       |   10 +++++-----
 net/ipv4/ip_options.c                 |   12 ++++++------
 net/ipv4/tcp.c                        |    2 +-
 net/ipv4/tcp_input.c                  |    2 +-
 net/ipv6/addrconf.c                   |    7 -------
 net/ipv6/ip6_fib.c                    |    2 +-
 net/ipv6/route.c                      |    5 ++---
 net/key/af_key.c                      |    2 +-
 net/rose/rose_route.c                 |    2 --
 net/socket.c                          |    3 ---
 net/xfrm/xfrm_policy.c                |    2 +-
 net/xfrm/xfrm_user.c                  |    2 ++
 22 files changed, 50 insertions(+), 54 deletions(-)

