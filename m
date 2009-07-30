From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Bonding ALB sends bogus packets
Date: Thu, 30 Jul 2009 13:06:56 -0700
Message-ID: <20090730130656.680e9152@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sf.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40223 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbZG3UHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2009 16:07:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding ALB mode builds packets with type, ETH_P_LOOP.

Well ETH_P_LOOP is defined as 0x0060 which looks completely bogus.
All Ethernet types less than 1536 are interpreted as 802.2 frames.
The result is that the resulting packet looks like a bogus 802.2
frame to the other host (or switch).  I have no idea what the 
initial design was or what the purpose of this code is, but it
should either send a real packet or nothing at all.

-- 
