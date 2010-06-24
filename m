From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 1/2] syncookies: do not store rcv_wscale in tcp
 timestamp
Date: Fri, 25 Jun 2010 00:14:16 +0200
Message-ID: <20100624221416.GA31116@nuttenaction>
References: <1277156925-7295-1-git-send-email-fw@strlen.de>
 <20100623202759.GA3581@nuttenaction>
 <20100624075304.GH27132@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:52407 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754135Ab0FXWOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 18:14:19 -0400
Content-Disposition: inline
In-Reply-To: <20100624075304.GH27132@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Florian Westphal | 2010-06-24 09:53:04 [+0200]:

>> I speculate that this behavior was and is not correct. I suppose that their is
>> a race between the SYN/ACK where we initial force a particular window scale
>> and the next time where we recalculate the window via tcp_select_initial_window().
>
>Yes, but it is not the only one. We also do a route lookup to get the
>current window size.

Is this critical in any sense? The window size is a pure passive variable, we
do not announce any window information to the peer. I don't get the problem
for the window size.

>> If the user change net.core.rmem_max or net.ipv4.tcp_rmem in between this
>> time, the recalculated window scale (rcv_wscale) can be smaller. But the
>> receiver still operates with the initial window scale and can overshot the
>> granted window - and bang.
>
>Why "bang"?
>Sure, its not nice, but is it such a severe problem that we have to keep
>rcv_wscale around in the timestamp?

IMHO if we want a 100% race free behavior yes.

>>  or disable window scaling and don't transmit any scaling option
>> when SYN cookies are active.
>
>No, I would rather see this patch rejected than that.

Sure? SYN cookies are only active if we suffer under acute memory pressure. We
are likely not in the ability to backup large buffer space - why not limit
the window to 2^16 bytes which is sufficient for 99.9999% of the use case?
I do not identify any _real_ advantages to speed up a connection when the
server is under fire.

Another solution is to accept this patch and assume that this race is
rather artificial nature and does not happened. Sure, the race is very
unlikely[TM].

HGN
