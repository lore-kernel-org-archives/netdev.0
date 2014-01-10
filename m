From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 0/3] atheros: modify statistics code
Date: Fri, 10 Jan 2014 17:08:20 +0100
Message-ID: <1389370103-3009-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:51124 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbaAJQJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 11:09:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following Ben Hutchings's advice on how to fill net_stats in alx [1],
this patch modifies the other atheros ethernet drivers
similarly. Minor whitespace/empty line changes in atl1c and atl1e to
make the code completely consistent between atl1c, atl1e, and alx
(after this [2]).

I don't have this hardware, so these patches have only been
compile-tested.


Detail of the changes:
* atl1/atl1c/atl1e
  - fix collisions computation
  - rx_dropped = rx_rrd_ov
  - rx_over_errors = 0
  - rx_missed_errors = 0
  - X_packets = X_ok + X_errors

* only atl1c/atl1e
  - add rx_rxf_ov to rx_errors

Note: These patches don't depend on the alx patchset [2], but the
commit-log messages reference it.


[1] http://www.spinics.net/lists/netdev/msg264930.html
[2] http://www.spinics.net/lists/netdev/msg265564.html

Sabrina Dubroca (3):
  atl1c: update statistics code
  atl1e: update statistics code
  atl1: update statistics code

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 31 ++++++++++++++++---------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 30 +++++++++++++++---------
 drivers/net/ethernet/atheros/atlx/atl1.c        | 16 ++++++-------
 3 files changed, 47 insertions(+), 30 deletions(-)

-- 
1.8.5.2
