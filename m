From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next v4 0/2] mlx4_en: Add PTP support
Date: Tue, 31 Dec 2013 11:39:38 -0600
Message-ID: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:60965 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab3LaRkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 12:40:13 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so13438383oag.12
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 09:40:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

This adds support to the mlx4_en driver to support running a PTP client
with hardware timestamp support.  It also allows synchronization of the
hardware timestamped packets with the system clock.

v2:
* Implemented mlx4_en_phc_adjfreq() in software.
* Protected timecounter with a spinlock
* Set the phc_index in mlx4_en_get_ts_info()
* Use a hard-coded ptp_clock_info.name

v3: is code identical to v2.  I simply finished testing it with
linuxptp, cleaned up the commit description a little and sent to davem.

v4:
* Initialize clock_lock
* Use reader/writer spinlock for clock_lock to improve performance when
 timetamping is enabled.

Shawn Bohrer (2):
  mlx4_en: Add PTP hardware clock
  mlx4_en: Only cycle port if HW timestamp config changes

 drivers/net/ethernet/mellanox/mlx4/en_clock.c   |  198 ++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |    3 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    6 +
 4 files changed, 202 insertions(+), 8 deletions(-)

-- 
1.7.7.6
