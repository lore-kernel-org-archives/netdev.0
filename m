From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 12:14:43 -0800 (PST)
Message-ID: <20061130.121443.116355312.davem@davemloft.net>
References: <20061130095232.GA8990@2ka.mipt.ru>
	<456EAD6E.6040709@yahoo.com.au>
	<20061130102205.GA20654@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nickpiggin@yahoo.com.au, mingo@elte.hu, wenji@fnal.gov,
	akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41613
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031371AbWK3UOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 15:14:41 -0500
To: johnpol@2ka.mipt.ru
In-Reply-To: <20061130102205.GA20654@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 30 Nov 2006 13:22:06 +0300

> It steals timeslices from other processes to complete tcp_recvmsg()
> task, and only when it does it for too long, it will be preempted.
> Processing backlog queue on behalf of need_resched() will break
> fairness too - processing itself can take a lot of time, so process
> can be scheduled away in that part too.

Yes, at this point I agree with this analysis.

Currently I am therefore advocating some way to allow
full input packet handling even amidst tcp_recvmsg()
processing.
