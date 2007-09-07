From: Jason Lunz <lunz@gehennom.net>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Fri, 7 Sep 2007 16:20:47 -0500
Message-ID: <20070907212044.GA9786@falooley.org>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <1189120020.4259.68.camel@localhost> <46E11A61.9030409@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li6-103.members.linode.com ([66.160.141.103]:2905 "EHLO
	smtp.falooley.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758476AbXIGWDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 18:03:06 -0400
Content-Disposition: inline
In-Reply-To: <46E11A61.9030409@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In gmane.linux.network, you wrote:
> But the CPU has done more work. The flood ping will always show 
> increased CPU with these changes because the driver always stays in the 
> NAPI poll list. For typical LAN traffic, the average CPU usage doesn't 
> increase as much, though more measurements would be useful.

I'd be particularly interested to see what happens to your latency when
other apps are hogging the cpu. I assume from your description that your
cpu is mostly free to schedule the niced softirqd for the device polling
duration, but this won't always be the case. If other tasks are running
at high priority, it could be nearly a full jiffy before softirqd gets
to check the poll list again and the latency introduced could be much
higher than you've yet measured.

Jason
