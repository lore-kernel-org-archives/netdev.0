From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 0/4] Convert network timestamps to be y2038 safe
Date: Wed, 24 Feb 2016 23:07:07 -0800
Message-ID: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
Cc: arnd@arndb.de, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org, y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34875 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756602AbcBYHIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 02:08:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduction:

The series is aimed at transitioning network timestamps to being
y2038 safe.
All patches can be reviewed and merged independently, except for
the [PATCH 2/4], which is dependent on the [PATCH 1/4].

Socket timestamps and ioctl calls will be handled separately.

Thanks to Arnd Bergmann for discussing solution options with me.

Solution:

Data type struct timespec is not y2038 safe.
Replace timespec with struct timespec64 which is y2038 safe.

Deepa Dinamani (4):
  kernel: time: Add current_nw_timestamp() for network timestamps
  net: ipv4: Use y2038 safe functions and data structures
  net: ipv4: tcp_probe: Replace timespec with timespec64
  net: sctp: Convert log timestamps to be y2038 safe

 include/linux/ip.h     |  2 ++
 include/linux/time64.h |  3 +++
 kernel/time/time.c     | 26 ++++++++++++++++++++++++++
 net/ipv4/icmp.c        |  5 +----
 net/ipv4/ip_options.c  | 13 +++++--------
 net/ipv4/tcp_probe.c   |  8 ++++----
 net/sctp/probe.c       | 10 +++++-----
 7 files changed, 46 insertions(+), 21 deletions(-)

-- 
1.9.1

Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-sctp@vger.kernel.org
