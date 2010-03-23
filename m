From: David Miller <davem@davemloft.net>
Subject: Re: [RFC Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Mon, 22 Mar 2010 20:49:39 -0700 (PDT)
Message-ID: <20100322.204939.146100390.davem@davemloft.net>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>
	<1269297081.3552.19.camel@calx>
	<4BA823D7.4010106@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	jmoyer@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35559
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754358Ab0CWDtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 23:49:17 -0400
In-Reply-To: <4BA823D7.4010106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 23 Mar 2010 10:13:43 +0800

> Matt Mackall wrote:
>> Seems like a lot of interface for something to be used by only a
>> couple
>> core drivers. Hopefully Dave has an opinion here.
>> 
> 
> Yeah, I worry about this too, maybe we can group those methods
> for netpoll together into another struct, and just put a pointer
> here?

This looks like it's tackled at the wrong layer, to be honest.

Teaching all of these layers about eachother's states is
going to end up being a nightmare in the end.

All of this "where is the npinfo" business can be handled
generically in net/core/dev.c I think, with none of these
callbacks.

For example, something like "if dev lacks ->npinfo, check
it's master".

Another thing, I wouldn't iterate over all devices, like I
see in the bonding poll controller method.  Just whichever
one supports netpoll you see first, use it and exit
immediately.  Don't send it to every single port, I can't
see how that might be desirable or useful.
