From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 02:06:19 -0700 (PDT)
Message-ID: <20100415.020619.00349859.davem@davemloft.net>
References: <1271318553.16881.2161.camel@edumazet-laptop>
	<20100415.012607.15449571.davem@davemloft.net>
	<1271321507.16881.2244.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757226Ab0DOJGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 05:06:15 -0400
In-Reply-To: <1271321507.16881.2244.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Apr 2010 10:51:47 +0200

> In any case, I think there is a fundamental problem with this sk
> caching. Because one packet can travel in many stacked devices before
> hitting the wire.
> 
> (bonding, vlan, ethernet) for example.
> 
> Socket cache is meaningfull for one level only...

We were talking the other day about that 'tun' change to orphan the
SKB on TX, and I mentioned the possibility of just doing this in some
generic location before we give the packet to the device ->xmit()
method.

Such a scheme could help with this problem too.
