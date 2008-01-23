From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4 0/9] TRIE performance patches
Date: Tue, 22 Jan 2008 21:58:31 -0800 (PST)
Message-ID: <20080122.215831.221891291.davem@davemloft.net>
References: <20080122233733.404145234@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44447
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753274AbYAWF6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 00:58:22 -0500
In-Reply-To: <20080122233733.404145234@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 22 Jan 2008 15:37:33 -0800

> 
> Time to handle a full BGP load (163K of routes).
> 
> Before:		Load		Dump		Flush
> hash		3.5		 0.5		0.7
> 2.6.23.14	3.4		19.3		10.3
> net-2.6.25	3.4		18.7		9.8
> 
> After:
> kmem_cache	3.8		13.0		7.2
> iter		3.9		12.3		6.9
> unordered	3.1		11.9		4.9
> find_node	3.1		 0.3		1.2
> 
> Load:	ip -batch iproute-table
> Dump:	ip route >/dev/null
> Flush:	ip route flush table main

Nice work Stephen, all 9 patches applied.

We'll need to think about that new -EBUSY behavior, it
might confuse routing daemons and similar, and therefore
we might need to find a way to fudge continuing the dump
instead of failing.
