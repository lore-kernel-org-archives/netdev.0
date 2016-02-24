From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/5] Flow dissector fixes and improvements
Date: Wed, 24 Feb 2016 09:29:31 -0800
Message-ID: <20160224172644.12339.92679.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35705 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbcBXR3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:29:33 -0500
Received: by mail-pa0-f41.google.com with SMTP id ho8so16461723pac.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 09:29:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to fix and/or improve a number of items within
the flow dissector code.  The main change out of all of this is that IPv4
and IPv6 fragmentation should now be handled better than it was.  As a
result we should see an improvement when handling things like IP fragment
reassembly as the skbs should now only have header data in the linear
portion of the buffer while the fragments will only hold payload data.

---

Alexander Duyck (5):
      flow_dissector: Check for IP fragmentation even if not using IPv4 address
      flow_dissector: Fix fragment handling for header length computation
      flow_dissector: Correctly handle parsing FCoE
      flow_dissector: Use same pointer for IPv4 and IPv6 addresses
      eth: Pull header from first fragment via eth_get_headlen


 net/core/flow_dissector.c |   45 ++++++++++++++++++++++++++-------------------
 net/ethernet/eth.c        |    3 ++-
 2 files changed, 28 insertions(+), 20 deletions(-)
