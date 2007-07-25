From: shemminger@oldman.hamilton.local
Subject: [PATCH 0/3] TCP timestamp hardening (update)
Date: Wed, 25 Jul 2007 11:44:35 +0100
Message-ID: <20070725104434.998037763@oldman.hamilton.local>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36663 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758803AbXGYLB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 07:01:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches deal with issues brought up by Gavin McCullagh
about reactions of Cubic and HTCP to hostile receivers that return
bogus timestamp options. If the receiver crafts a timestamp that is
larger than the original, then some of the congestion control algorithms
maybe come unfair.

The solution in these patches is to only use local values to measure
RTT for congestion control.  The timestamp is still used as described
in RFC's to measure RTT used for retransmit timer.

Thank you to Sangtae Ha for testing, these, see:
  http://netsrv.csc.ncsu.edu/net-2.6.22/stephen_lowres/
He also found some pre-existing problems with TCP-LP that might
be related to NAPI on the receiver.

This should go into 2.6.23. But not into the stable kernel
since the risk of causing regression is greater than the possible
risk exposure.

-- 

