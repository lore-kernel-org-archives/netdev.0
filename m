From: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Thu, 24 Jan 2013 13:22:23 +0100
Message-ID: <20130124122223.GQ4608@sociomantic.com>
References: <20130122161038.GG4608@sociomantic.com>
 <1358873142.3464.3964.camel@edumazet-glaptop>
 <20130122165929.GH4608@sociomantic.com>
 <1358874800.3464.4002.camel@edumazet-glaptop>
 <50FED7CE.1030008@hp.com>
 <20130122184245.GJ4608@sociomantic.com>
 <50FF0C25.9000300@hp.com>
 <20130123104736.GK4608@sociomantic.com>
 <510039C8.7040401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:56365 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979Ab3AXMWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 07:22:31 -0500
Content-Disposition: inline
In-Reply-To: <510039C8.7040401@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 11:28:08AM -0800, Rick Jones wrote:
> >Then if syncookies are enabled, the time spent in connect() shouldn't be
> >bigger than 3 seconds even if SYNs are being "dropped" by listen, right?
> 
> Do you mean if "ESTABLISHED" connections are dropped because the
> listen queue is full?  I don't think I would put that as "SYNs being
> dropped by listen" - too easy to confuse that with an actual
> dropping of a SYN segment.

I was just kind of quoting the name given by netstat: "SYNs to LISTEN
sockets dropped" (for kernel 3.0, I noticed newer kernels don't have
this stat anymore, or the name was changed). I still don't know if we
are talking about the same thing.

> But yes, I would not expect a connect() call to remain incomplete
> for any longer than it took to receive an SYN|ACK from the other
> end.

So the only reason to experience these high times spent in connect()
should be because a SYN or SYN|ACK was actually loss in a lower layer,
like an error in the network device or a transmission error?

> That would be 3 (,9, 21, etc...) seconds on a kernel with 3
> seconds as the initial retransmission timeout.

Which can't be changed without recompiling, right?

Thanks!

-- 
Leandro Lucarella
sociomantic labs GmbH
http://www.sociomantic.com
