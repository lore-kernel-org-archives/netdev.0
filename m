From: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
Subject: [PATCH net 0/2] net: mv643xx_eth: TSO TX data corruption fixes
Date: Sun, 18 Oct 2015 16:02:42 +0200
Message-ID: <1445176964-22760-1-git-send-email-philipp@familie-kirchhofer.de>
Cc: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.196.166.47.78.clients.your-server.de ([78.47.166.196]:42170
	"EHLO vserver.familie-kirchhofer.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752554AbbJROIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 10:08:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

as previously discussed [1] the mv643xx_eth driver has some
issues with data corruption when using TCP segmentation offload (TSO).

The following patch set improves this situation by fixing two data
corruption bugs in the TSO TX path.

Before applying the patches repeatedly accessing large files located on
a SMB share on my NSA325 NAS with TSO enabled resulted in different
hash sums, which confirmed that data corruption is happening during
file transfer. After applying the patches the hash sums were the same.

As this is my first patch submission please feel free to point out any
issues with the patch set.

[1] http://thread.gmane.org/gmane.linux.network/336530

Best wishes,
  Philipp

Philipp Kirchhofer (2):
  net: mv643xx_eth: Ensure proper data alignment in TSO TX path
  net: mv643xx_eth: Defer writing the first TX descriptor when using TSO

 drivers/net/ethernet/marvell/mv643xx_eth.c | 48 +++++++++++++++++++++++++-----
 1 file changed, 40 insertions(+), 8 deletions(-)
