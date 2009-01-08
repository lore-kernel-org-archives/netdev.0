From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 8 Jan 2009 14:56:28 -0800
Message-ID: <20090108145628.3cdbc80a@extreme>
References: <20090108135614.23aed603@extreme>
	<20090108.135819.103389689.davem@davemloft.net>
	<20090108140122.5488d84c@extreme>
	<20090108.140339.00980764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40875 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763011AbZAHW4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 17:56:31 -0500
In-Reply-To: <20090108.140339.00980764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Jan 2009 14:03:39 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 8 Jan 2009 14:01:22 -0800
> 
> > Fine, it won't be the first or last vendor specific kernel patch.
> 
> You're just supporting my argument even more.
> 
> If all the dists ship it and turn it on, then logically we should
> include it and have it on by default.
> 
> But you know we can't do that.
> 
> Therefore, it's detrimental for the dists to ship it too because it
> does break things.
> 
> I know you want to shove this in, via some avenue, but it is really
> so undesirable to cope with existing behavior?

Reading back in the archives, this has come up before. The real problem
is that when link goes down and comes back the address needs to be
reverified for DAD. Maybe instead of deleting addresses they should
be moved to another list for restart.

It is a real problem for routing daemons like hostapd and zebra since
the kernel address deletion looks a lot like a user address deletion.
Since Vyatta has the luxury of a configuration/scripting layer, this
means the state space is contained (we know what the address was),
I'll just hack around it there for now until a better solution arises.
