From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 17:48:16 -0700
Message-ID: <20061027174816.29bd6563@localhost.localdomain>
References: <20061027145913.04dc0e5f@dxpl.pdx.osdl.net>
	<20061027.151238.59655130.davem@davemloft.net>
	<20061027152149.42bcb539@dxpl.pdx.osdl.net>
	<20061027.152444.48528262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51597 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751437AbWJ1Ast (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 20:48:49 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061027.152444.48528262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

How about another way of controlling this via sysctl.

First, add code to for read only:
	/proc/sys/net/ipv4/tcp_available_congestion_control  (or shorter name)
this will show all things compiled in (even if not loaded yet). Similar
to /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies

Second, add flag (allowed) to the tcp_congestion structure [inverse of
earlier restricted]

Third, add read-write
	/proc/sys/net/ipv4/tcp_allowed_congestion_control
to show and set/clear the allowed flag. Default value would be
"reno xxx" where xxx is what ever the default value from the kernel
config is (currently cubic).

I would use sysfs for this, but it make sense not to spread TCP stuff into
both sysctl and sysfs.
