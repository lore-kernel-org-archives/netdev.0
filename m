From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 0/2 net-next] sunvnet: bug fixes
Date: Thu, 6 Nov 2014 14:50:54 -0500
Message-ID: <20141106195054.GD6238@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com,
	david.stevens@oracle.com, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24986 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaKFTvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:51:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series has a coding-style fix and a bug fix.

The coding style fix (patch 1) is the extra indentation flagged by
Ben Hutchings:
  http://marc.info/?l=linux-netdev&m=141529243409594&w=2

The bugfix (patch 2) is the following: 
when vnet_event_napi() is  called as part of napi_resume 
(i.e., continuation of a previous NAPI read that was truncated 
due to budget constraints), and then finds no more packets to read, 
the code was trying to avoid an additional trip through ldc_rx 
as an optimization. However, when this corner case happens, we would
need to reset a number of dring state bits such as rcv_nxt carefully, 
which quickly becomes complex and hacky.  The cleaner solution
is to just roll back to vnet_poll, re-enable interrupts and set up
dring state as was done in the pre-NAPI version of the driver.


Sowmini Varadhan (2):
  Fix indentation in maybe_tx_wakeup()
  Return from vnet_napi_event() if no packets to read

 drivers/net/ethernet/sun/sunvnet.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

-- 
1.8.4.2
