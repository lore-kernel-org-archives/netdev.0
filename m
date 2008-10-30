From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Thu, 30 Oct 2008 11:15:26 -0700
Message-ID: <20081030111526.7d9bb0f8@extreme>
References: <20081009231759.GA8664@tservice.net.ru>
	<20081010115518.GA3159@tservice.net.ru>
	<20081010115725.GD19487@elte.hu>
	<200810250025.35734.rjw@sisk.pl>
	<20081026112924.GA29258@ioremap.net>
	<20081026122300.GA30905@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>,
	Evgeniy Polyakov <s0mbre@tservice.net.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53793 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754965AbYJ3SP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 14:15:29 -0400
In-Reply-To: <20081026122300.GA30905@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anyone looked into the impact of port randomization on this benchmark.
If it is generating lots of sockets quickly there could be an impact:
  * port randomization causes available port space to get filled non-uniformly
    and what was once a linear scan may have to walk over existing ports.
    (This could be improved by a hint bitmap)

  * port randomization adds at least one modulus operation per socket
    creation. This could be optimized by using a loop instead.
