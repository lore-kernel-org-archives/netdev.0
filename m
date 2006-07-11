From: Ben Greear <greearb@candelatech.com>
Subject: Question on device events and unregister_netdev.
Date: Tue, 11 Jul 2006 16:27:25 -0700
Message-ID: <44B433DD.8070100@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:54660 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932235AbWGKX10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 19:27:26 -0400
Received: from [71.112.216.116] (pool-71-112-216-116.sttlwa.dsl-w.verizon.net [71.112.216.116])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k6BNRPpi000544
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 16:27:26 -0700
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I'm working on stacking some virtual interfaces, and ran into a problem with
locking.

Basically, I have an ethernet-like device, and on top of that I am putting
802.1Q vlans..and on top of that, some other vlan (macvlan).

In the event notifier for the vlan, I attempt to delete all vlans who's
under-lying device is going away.  I do the same for the macvlan.

Currently, I am setting a deadlock warning because the macvlan code
is calling unregister_netdev, but the 'rmmod' method already has
a lock in there due to having earlier called unregister_netdev on the
.1q vlan.


So, the question is:  Should I be calling unregister_netdev from the notifier
callback?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

