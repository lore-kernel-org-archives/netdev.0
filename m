From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Tue, 07 Nov 2006 12:45:57 -0800 (PST)
Message-ID: <20061107.124557.21592397.davem@davemloft.net>
References: <1162924354.10806.172.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11208
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751803AbWKGUp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 15:45:59 -0500
To: tim.c.chen@linux.intel.com
In-Reply-To: <1162924354.10806.172.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 07 Nov 2006 10:32:34 -0800

[ Please bring up networking questions on "netdev@vger.kernel.org"
  as that is the place where networking developers read bug reports
  and questions, they by-in-large do not read linux-kernel at all. ]

> [TCP]: Send ACKs each 2nd received segment
> commit: 1ef9696c909060ccdae3ade245ca88692b49285b
> http://kernel.org/git/?
> p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1ef9696c909060ccdae3ade245ca88692b49285b
> 
> reduced Volanomark benchmark throughput by 10%.  
> This is because Volanomark sends 
> short message (<100 bytes) on its TCP
> connections.  This patch increases the number of ACKs 
> traffic by 3.5 times.  
> 
> By adopting this patch, we assume that with
> small segment, having short delay is important 
> enough that we are willing to reduce bandwidth 
> with more ACKs.  
> 
> Is there any real application out there
> that this new behavior could be a concern?

That's unfortunate, because without that patch connections can hang
which is more important to fix than your performance test.  :-)

If we don't ACK every two segments, stacks which grow the congestion
window based upon packet counting will not grow the congestion window
properly when they are sending smaller than MSS sized segments.

This topic has been discussed quite a bit, you may want to do some
searching in the netdev archives to read some of that.
