From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [RFC PATCH v2 0/2] Add support for hardware-offloaded encapsulation
Date: Thu, 25 Oct 2012 12:38:58 -0700
Message-ID: <1351193940-11427-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15190 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759761Ab2JYUBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 16:01:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an RFC and not intended to get merged at the moment.
The series contains updates to add in the NIC Rx and Tx checksumming support
for encapsulated packets.

The sk_buff needs to somehow have information of the inner packet, and adding
three fields for the inner mac, network and transport headers was the prefered
approach. 

Not adding these fields would mean that the drivers would need to parse the
sk_buff data in hot-path, having a negative impact in the performance.

Adding in sk_buff a pointer to the skbuff of the inner packet made sense, but
would be a complicated change as assumptions needed to be made with regards to
helper functions such as skb_clone() skb_copy(). Also code for the existing
encapsulation protocols (such as VXLAN and IP GRE) had to be reworked, so the
decision was to have the simple approach of adding these three fields.

Version 2 has the mbox format corrected for this patch.
