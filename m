From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v2 0/3] atheros: modify statistics code
Date: Sun, 12 Jan 2014 18:50:37 +0100
Message-ID: <1389549040-8785-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:44671 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbaALRvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 12:51:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following Ben Hutchings's advice on how to fill net_stats in alx [1],
this patch modifies the other atheros ethernet drivers
similarly. Minor whitespace/empty line changes in atl1c and atl1e to
make the code completely consistent between atl1c, atl1e, and alx.

I don't have this hardware, so these patches have only been
compile-tested.


v2 (changes only in atl1):
 - don't set soft_stats.rx_missed_errors (Ben)
 - add errors to soft_stats.{rx,tx}_packets (Ben)
 - add soft_stats.rx_dropped field and update soft_stats.rx_dropped
   instead of netdev->stats (overwritten) outside of the stats
   update function

Detail of the changes (v1):
* atl1/atl1c/atl1e
  - fix collisions computation
  - rx_dropped = rx_rrd_ov
  - rx_over_errors = 0
  - rx_missed_errors = 0
  - X_packets = X_ok + X_errors

* only atl1c/atl1e
  - add rx_rxf_ov to rx_errors


[1] http://www.spinics.net/lists/netdev/msg264930.html


Sabrina Dubroca (3):
  atl1c: update statistics code
  atl1e: update statistics code
  atl1:  update statistics code

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 31 +++++++++++-------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 30 ++++++++++-------
 drivers/net/ethernet/atheros/atlx/atl1.c        | 43 ++++++++++++++-----------
 drivers/net/ethernet/atheros/atlx/atl1.h        |  1 +
 4 files changed, 65 insertions(+), 40 deletions(-)

-- 
1.8.5.2
