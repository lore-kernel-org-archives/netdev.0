From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PROBLEM] Bonding driver in linux-2.6.21-rc6-mm1
Date: Sat, 28 Apr 2007 23:55:35 +0200
Message-ID: <4633C2D7.9040509@trash.net>
References: <200704262058.33087.ve@vetienne.net>	<200704272205.29131.ve@vetienne.net>	<20070427153237.03f3b59c.akpm@linux-foundation.org>	<200704282237.42753.ve@vetienne.net> <20070428143102.f39299b5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Vincent ETIENNE <ve@vetienne.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46025 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbXD1V4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 17:56:06 -0400
In-Reply-To: <20070428143102.f39299b5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sat, 28 Apr 2007 22:37:42 +0200 Vincent ETIENNE <ve@vetienne.net> wrote:
> 
>>>because we thought we'd fixed the rtnl_lock() problems in 2.6.21-rc7-mm2.
>>>Are you sure that log is from 2.6.21-rc7-mm2?
>>
>>
>>Yes. I have retested it another time ( for adding the small usb debug 
>>message ) and get the same message a new time.
>>
>>Maybe a tiny difference : only eth0 was setup during boot ( bond0 and eth1 was 
>>not setup - volontary  - to avoid problem that could interfere with usb ). 
>>Ony after having done my usb test, i have stopped the eth0, setup bond 
>>interface and restart bond interface and got the same problem with the same 
>>back trace.
> 
> 
> OK, thanks.


The failed RTNL assertion here is unrelated to the mutex initialization
bug in 2.6.1-rc7-mm1. The bonding driver is not holding the rtnl_mutex
while calling dev_set_mac_address (and can not since its called from
a timer). I believe this is a known problem to the bonding maintainers.
