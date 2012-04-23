From: Chris Boot <bootc@bootc.net>
Subject: [PATCH RFC 0/2] e1000e: 82574 also needs ASPM L1 completely disabled
Date: Mon, 23 Apr 2012 22:29:36 +0100
Message-ID: <1335216578-21542-1-git-send-email-bootc@bootc.net>
References: <9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
Cc: linux-kernel@vger.kernel.org, nix@esperi.org.uk,
	carolyn.wyborny@intel.com, Chris Boot <bootc@bootc.net>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After much toing and froing on LKML, netdev and the e1000 mailing lists
over the past few months we've determined that the 82574L needs to have
both ASPM L0s and L1 disabled or else it's likely to lock up. This
little series does just that, also cleaning up some now-unnecessary code
that disables L1 on the 82573 and 82574 if the MTU is greater than 1500
bytes.

Please note I haven't as-yet tested this code at all, but I do know that
disabling ASPM L1 on these NICs (using setpci) fixes the hangs that I
have been seeing on my Supermicro servers with X9SCL-F boards. I hope to
get the chance to install an updated kernel on my two afftected servers
later this week.

Chris Boot (2):
  e1000e: Disable ASPM L1 on 82574
  e1000e: Remove special case for 82573/82574 ASPM L1 disablement

 drivers/net/ethernet/intel/e1000e/82571.c  |    3 ++-
 drivers/net/ethernet/intel/e1000e/netdev.c |    8 --------
 2 files changed, 2 insertions(+), 9 deletions(-)

-- 
1.7.10
