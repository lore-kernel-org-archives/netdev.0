From: Ben Greear <greearb@candelatech.com>
Subject: netlink stats and message ordering.
Date: Fri, 19 Nov 2010 10:20:17 -0800
Message-ID: <4CE6BFE1.6020404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40066 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab0KSSUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 13:20:18 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id oAJIKHnp021246
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 10:20:17 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a single netlink socket that listens for various things,
as well as requests netdev stats and such.

I am seeing a case during interface creation (mac-vlans) where I get one set of stats
that appears to show 1 packet transmitted, and then immediately after that,
a second set of stats for the same device that shows all zero counters.

Since I'm trying to handle wraps properly, my code tends to consider this
a wrap and of course the numbers go all wrong since it wasn't really a wrap.

I am wondering if it's possible that netlink messages are somehow being
re-ordered before they are sent to my application?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

