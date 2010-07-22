From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: mirred, redirect action vs. dev refcount issue
Date: Wed, 21 Jul 2010 17:00:24 -0700
Message-ID: <20100721170024.60cd9ef4@nehalam>
References: <20100721162426.5aa4b646@nehalam>
	<20100721.163955.12041610.davem@davemloft.net>
	<20100721165247.6d1dd879@nehalam>
	<20100721.165802.111593910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38700 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759081Ab0GVAA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 20:00:27 -0400
In-Reply-To: <20100721.165802.111593910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jul 2010 16:58:02 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 21 Jul 2010 16:52:47 -0700
> 
> > On Wed, 21 Jul 2010 16:39:55 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> If it is the action rule holding onto the device, it should have
> >> an appropriate netdevice notifier handler.
> > 
> > There is no notifier there, and the module doesn't keep track of
> > list of filters. So that is why it has to be done at act api level.
> 
> Any rule, or route, or whatever that makes references to devices must
> transparently accomodate the requested removal or downing of a device.
> 
> There is no way around this.
> 
> So either the action code needs to keep track of it's table entries on
> some global list that can be traversed at notifier time, or we go with
> the ifindex thing.
> 
> Whether the ifindex or the global list + delete scheme is better is a
> topic for discussion.  Since from the user's perspective it is unclear
> which semantic is less surprising, entries disappearing or suddenly
> stop working (or start applying to a different device which has taken
> a previous one's ifindex!).

ifindex is unique (until integer wraps) so that soft reference
works.

-- 
