From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: setsockopt()
Date: Wed, 9 Jul 2008 22:43:30 +0400
Message-ID: <20080709184329.GC5383@2ka.mipt.ru>
References: <20080707.144912.76654646.davem@davemloft.net> <20080708045443.GA7726@2ka.mipt.ru> <20080708020235.388a7bd5.billfink@mindspring.com> <adar6a4x510.fsf@cisco.com> <20080708134845.2372a483@speedy> <20080708180500.e8a61231.billfink@mindspring.com> <20080709052534.GA8157@2ka.mipt.ru> <20080709014758.d59be0d8.billfink@mindspring.com> <20080709060341.GA29743@2ka.mipt.ru> <20080709181122.GB488@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:37022 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648AbYGISpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 14:45:14 -0400
Content-Disposition: inline
In-Reply-To: <20080709181122.GB488@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2008 at 02:11:22PM -0400, J. Bruce Fields (bfields@fieldses.org) wrote:
> > Yeah, its a bit confusing. It probably was copypasted, there is no
> > default, but minimum possible value.
> 
> I don't understand; what do you mean by "there is no default"?  (And if
> not, what does tcp_wmem[1] mean?)

I meant there is no default value for tcp_w/rmem[2], which is calculated
based on tcp_mem, which in turn is calculated based on amount RAM of in
the system. tcp_wmem[2] will be at least 64k, but its higher limit
(calculated by system, which of course can be overwritten) is RAM/256 on
x86 (iirc only low mem is counted, although that was different in
various kernel versions), but not more than 4Mb.

tcp_wmem[1] means initial send buffer size, it can grow up to tcp_wmem[2].
There is a default for this parameter. Actually all this numbers are a
bit fluffy, so they are kind of soft rules for socket memory accounting
mechanics.

-- 
	Evgeniy Polyakov
