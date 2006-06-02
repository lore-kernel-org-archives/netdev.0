From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Fri, 2 Jun 2006 11:01:49 +0400
Message-ID: <20060602070149.GA12213@2ka.mipt.ru>
References: <20060601060424.GA28087@2ka.mipt.ru> <20060601001825.A21730@openss7.org> <20060601063012.GC28087@2ka.mipt.ru> <20060601004608.C21730@openss7.org> <20060601070136.GA754@2ka.mipt.ru> <20060601011125.C22283@openss7.org> <20060601083805.GB754@2ka.mipt.ru> <20060601042457.B25584@openss7.org> <20060601110625.GA15069@2ka.mipt.ru> <20060601124010.C554@openss7.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Brian F. G. Bidulock" <bidulock@openss7.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42719 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751231AbWFBHCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 03:02:09 -0400
To: David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060601124010.C554@openss7.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 01, 2006 at 12:40:10PM -0600, Brian F. G. Bidulock (bidulock@openss7.org) wrote:
> So what are your thoughts about my sequence number approach (for
> connected sockets)?

Depending on how you are going to use it.
Generic socket code does not have TCP sequence numbers since it must
work with all supported protocols.
Netchannels also do not know about internals of the packet by design,
since all protocol processing is performed at the end peer.

Sequence number can be wrapped in minutes in current networks and even
faster tomorrow, that is why PAWS was created.

Your idea about reinserting the socket does not scale in 1Gbit
environment, and definitely will not in 10Gbit.

Probably it is possible to create second hash table for TCP sockets only
and use that table first in protocol handler, but it requires some
research to prove the idea.

-- 
	Evgeniy Polyakov
