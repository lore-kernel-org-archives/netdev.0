From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
 2.6.29-rc6
Date: Tue, 24 Feb 2009 18:35:54 -0500
Message-ID: <20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com>
References: <20090224182147.2150468e@dhcp-100-2-144.bos.redhat.com>
	<20090224.152704.210992553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49020 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156AbZBXXgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 18:36:05 -0500
In-Reply-To: <20090224.152704.210992553.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Feb 2009 15:27:04 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Chuck Ebbert <cebbert@redhat.com>
> Date: Tue, 24 Feb 2009 18:21:47 -0500
> 
> > (This doesn't happen on 2.6.27/28)
> > 
> > tw is NULL at net/ipv6/inet6_hashtables.c:261:
> > 
> > 	if (twp != NULL) {
> > 		*twp = tw;
> > ===>		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
> > 	} else if (tw != NULL) {
> > 
> > I can reproduce this on real hardware on x86_64 too...
> 
> How? :-)

Oops, forgot to add the bug URL:

https://bugzilla.redhat.com/show_bug.cgi?id=486889

Steps to Reproduce:
1. Get minirpc 0.3.2 [http://minirpc.cs.cmu.edu/download/minirpc-0.3.2.tar.gz]
2. Run ./configure ; make ; make check
