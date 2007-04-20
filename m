From: Ben Greear <greearb@candelatech.com>
Subject: Associating connection tracking with a physical device.
Date: Fri, 20 Apr 2007 15:50:12 -0700
Message-ID: <462943A4.5060309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:55506 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767299AbXDTWuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 18:50:13 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l3KMoCW5030510
	for <netdev@vger.kernel.org>; Fri, 20 Apr 2007 15:50:12 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am trying to NAT routed connections between pairs of devices very
much like the etun patch recently posted.

As far as I can tell, this is failing because the connection tracking
does not take the interface into account.  The result is that if you
send on etun1a, receive on etun1b, and then route internally to
etun2a for transmit, the packet uses the same nfct (printk shows
the 'id' of the ct is the same even though the skb->dev has changed.)
This appears to make it impossible to NAT on etun2a in this scenario.

I believe what is needed to make this work is the addition of some
extra fields in the conn-tracking tuple, or perhaps some explicit test
for the outgoing netdev.

Does that sound like the right approach for enabling NAT in this case?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

