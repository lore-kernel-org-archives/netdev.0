From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: (unknown)
Date: Thu, 25 Oct 2012 11:29:11 -0700
Message-ID: <1351189753-5912-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756494Ab2JYSb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 14:31:58 -0400
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [RFC PATCH 0/2] Add support for hardware-offloaded encapsulation

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
