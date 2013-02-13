From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/2] gianfar: make local stats atomic64
Date: Tue, 12 Feb 2013 19:24:22 -0500
Message-ID: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43640 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759221Ab3BMAYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:24:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric noticed that the handling of local u64 ethtool counters for
this driver commonly found on Freescale ppc-32 boards was racy.

However, before converting them over to atomic64_t, I noticed
that an internal struct was being used to determine the offsets
for exporting this data into the ethtool buffer, and in doing
so, it assumed that the counters would always be u64.  Rather
than keep this implicit assumption, a simple code cleanup gets
rid of the struct completely, and leaves less conversion sites.

The alternative solution would have been to take advantage of
the fact that the counters are all relating to error conditions,
and hence make them internally u32.  In doing so, we'd be assuming
that U32_MAX of any particular error condition is highly unlikely.
This might have made sense if any increments were in a hot path.

Tested with "ethtool -S eth0" on sbc8548 board.

Paul.
--

The following changes since commit 0790bbb68f9d483348c1d65381f3dd92602bfd05:

  netpoll: cleanup sparse warnings (2013-02-11 19:19:58 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git gfar-ethtool-atomic

for you to fetch changes up to 212079df6d77c0daada96b1d906f4b7749871411:

  gianfar: convert u64 status counters to atomic64_t (2013-02-12 19:08:27 -0500)

----------------------------------------------------------------
Paul Gortmaker (2):
      gianfar: remove largely unused gfar_stats struct
      gianfar: convert u64 status counters to atomic64_t

 drivers/net/ethernet/freescale/gianfar.c         | 26 ++++++++--------
 drivers/net/ethernet/freescale/gianfar.h         | 39 +++++++++++-------------
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 17 +++++------
 3 files changed, 37 insertions(+), 45 deletions(-)
