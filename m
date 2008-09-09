From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 09:33:23 -0700
Message-ID: <48C6A553.2070901@hp.com>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:12448 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbYIIQd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 12:33:26 -0400
In-Reply-To: <48C6052D.2080203@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Most of the apps where people care about this enough to complain to 
> their vendor (the cases I hear about) are in messaging apps, where 
> they're relaying a stream of events that have little to do with each 
> other, and they want TCP to maintain the integrity of the connection and 
> do a modicum of bandwidth management, but 40 ms stalls greatly exceed 
> their latency tolerances.

What _are_ their latency tolerances?  How often are they willing to 
tolerate a modicum of TCP bandwidth management?  Do they go ape when TCP 
sits waiting not just for 40ms, but for an entire RTO timer?

> Using TCP_NODELAY is often the least bad option, but sometimes it's
> infeasible because of its effect on the network, and it certainly
> adds to the network stack overhead.  A more tunable Nagle delay would
> probably serve many of these apps much better.

If the applications are sending streams of logically unrelated sends 
down the same socket, then setting TCP_NODELAY is IMO fine.  Where it 
isn't fine is where these applications are generating their logically 
associated data in two or more small sends.  One send per message good. 
Two sends per message bad.

BTW, is this magical mystery Solaris ndd setting "tcp_naglim_def?"  FWIW 
I believe there is a similar setting by the same name in HP-UX.

rick jones
