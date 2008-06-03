From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 3 Jun 2008 14:40:56 -0700
Message-ID: <20080603144056.2c7ec127@extreme>
References: <20080603104640.21026cdb@extreme>
	<20080603.105308.196677970.davem@davemloft.net>
	<20080603113411.0af753d8@extreme>
	<20080603.120640.151150916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47957 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540AbYFCVk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 17:40:57 -0400
In-Reply-To: <20080603.120640.151150916.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Jun 2008 12:06:40 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 3 Jun 2008 11:34:11 -0700
> 
> > On Tue, 03 Jun 2008 10:53:08 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > If it's a route behavioral attribute, make it as such and add
> > > a new rtnetlink route attribute.  If it's not there, existing
> > > behavior is maintained.
> > 
> > How would this work for system generated routes which occur
> > when address is added to interface?
> 
> Ok, then this takes us back to making userland take care of it.
> 
> You say this is difficult, by how different is this from any
> other kind of event response and synchronization that these
> routing daemons have to do already?

The problem is more that the zebra code is keeping track of the
RIB and has flags as well. Also, since maintainers are BSD/Solaris
based, it makes life harder. 

Have already fixed a number of bugs in that area, of the route
code where connected and recursive routes aren't getting cleared.
It's not impossible to fix, just a bigger burden.
