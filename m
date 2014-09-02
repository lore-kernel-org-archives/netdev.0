From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v2 0/2] sunvnet: Reduce LDC message overhead.
Date: Tue, 2 Sep 2014 12:19:36 -0400
Message-ID: <20140902161936.GA31516@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, raghuram.kothakota@oracle.com,
	sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50416 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426AbaIBQTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:19:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patchset has an updated version of the v1 changes to reduce the
overhead from LDC messages. 

Re-submitting both patches for completeness.

- Send the minimum number of start and stop messages between producer
  and consumer. 
  Changes since v1 to pull out the unused label `again' and the unused
  `retries' variable

- When reading the descriptor rings, don't give up as soon as a dring
  that is not VIO_DESC_READY is found. 
  Changes since v1: the `again' label and retries variable belong to
  this patch.

I understand the Puristic objection to the polling-delay from
patch 2/2, but the practical reality is that when there is
a burst of data, and performance is actually most critical, 
the overhead from hastily sending an LDC stop and then 
processing another LDC start message is far greater than the 
slight penalty of a small delay when the network traffic is light.

Note that I'm separately working on moving the data handling to a
bottom-half or softirq context, where the poll-based delay will be
even less critical.  We could also consider adding a procfs or ethtool
based knob to disable the fudge-factored delay, and avoid the minor
polling penalty.

Sowmini Varadhan (2):
  Avoid sending superfluous LDC messages.
  Re-check for a VIO_DESC_READY data descriptor after short udelay()

 drivers/net/ethernet/sun/sunvnet.c | 87 ++++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sun/sunvnet.h |  4 ++
 2 files changed, 83 insertions(+), 8 deletions(-)

-- 
1.8.4.2
