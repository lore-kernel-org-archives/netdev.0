From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 04 May 2010 14:38:24 -0700 (PDT)
Message-ID: <20100504.143824.82823095.davem@davemloft.net>
References: <OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com>
	<20100504.005757.97355845.davem@davemloft.net>
	<4BE031FA.6040006@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932152Ab0EDViR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 17:38:17 -0400
In-Reply-To: <4BE031FA.6040006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 04 May 2010 10:40:58 -0400

> Not exactly.  It fixes the case where it's wrong by default, but
> the corner case of setting it to -1 via setsockopt() says:
> 
>     x == -1:       use kernel default
> 
> But that will revert back to the kernel using 64 on the next transmit.
> I can work on an update to this that makes a new mcast_hops per-interface
> setting and makes ip6_dst_hoplimit() aware of it.  Or even easier, just
> have setsockopt() trap the -1 and set np->mcast_hops to 1.  Built but
> untested patch below.

I thought that we agreed that when the user explicitly asks for "-1"
it should get the behavior right now, with is to use
ip6_dst_hoplimit()?  I think I even acknowledged when Elliot mentioned
this explicitly, and I think it's a good idea.
