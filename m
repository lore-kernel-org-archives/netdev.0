From: Cong Wang <amwang@redhat.com>
Subject: RE: TCP delayed ACK heuristic
Date: Thu, 20 Dec 2012 20:41:10 +0800
Message-ID: <1356007270.25310.20.camel@cr0>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
	 <1355900436.6665.16.camel@cr0> <50D209E9.2000504@hp.com>
	 <20121219.125939.1674292599518627751.davem@davemloft.net>
	 <1355973829.25310.5.camel@cr0>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B70FC@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org, greearb@candelatech.com,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tgraf@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751427Ab2LTMlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 07:41:31 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70FC@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 09:57 +0000, David Laight wrote:
> > So, can we at least have a sysctl to control the timeout of the delayed
> > ACK? I mean the minimum 40ms. TCP_QUICKACK can help too, but it requires
> > the receiver to modify the application and has to be set every time when
> > calling recv().
> 
> A sysctl in inappropriate - it affects the entire TCP protocol stack.
> 
> You want different behaviour for different remote hosts (probably
> different subnets).
> In particular your local subnet is unlikely to have packet loss
> and very likely to have a very low RTT.
> 
> AFAICT a lot of the recent 'tuning' has been done for web/ftp
> servers that are very remote from the client. These connections
> are also request-response ones - quite often with large responses.
> 
> IMHO This has been to the detriment of local connections.
> 

A customer prefers faster response in their low-loss environment, 40ms
is not good. Of course, they are supposed to know their environment when
they tune this.

Or maybe a sysctl equals to TCP_QUICKACK?
