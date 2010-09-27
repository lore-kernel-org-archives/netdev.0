From: Yuri Chislov <yuri@itinteg.net>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not equal to /proc/sys/net/ipv4/tcp_syn_retries
Date: Mon, 27 Sep 2010 10:07:06 +0200
Message-ID: <201009271007.06705.yuri@itinteg.net>
References: <bug-18952-10286@https.bugzilla.kernel.org/> <20100922020212.d2aaec57.akpm@linux-foundation.org> <20100924.200557.229751150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-0.itinteg.net ([212.235.43.25]:42280 "EHLO gw-0.itinteg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab0I0INs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 04:13:48 -0400
In-Reply-To: <20100924.200557.229751150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  It looks like the behavior changed in 2.6.32. 2.6.32 and up, uses some 
calculation instead of a direct definition of the retries number, that makes it 
harder to achieve the necessary system behavior.

 The default behavior of the system changed completely
(the old default connect timeout was ~ 180 seconds, while the new one is ~21 
sec). 

The new behavior invalidates the kernel documentation and tcp man page.

It's not possible to set a connect timeout > 25 sec in the applications while 
using the default values in /proc. 

>From my view point is regression.

On Saturday, September 25, 2010 05:05:57 am David Miller wrote:
> tcp_syn_retries is not an exact calculation.
> 
> It is input into a calculation which estimates how long that many
> retransmits (with suitable backoff applied) will take, and that time
> estimte in turn determines the time limit for when we'll kill the
> connection attempt.
> 
> Feel free to update the documentation in
> Documentation/networking/ip-sysctl.txt to more closely match the
> behavior.
> 
> The logic is in net/ipv4/tcp_timer.c:retransmits_timed_out().
