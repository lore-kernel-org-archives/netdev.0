From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sun, 22 Jul 2007 09:10:23 +1000
Message-ID: <1185059423.6344.53.camel@localhost.localdomain>
References: <1185002071.6344.21.camel@localhost.localdomain>
	 <20070721.004234.122616332.davem@davemloft.net>
	 <1185004811.6344.37.camel@localhost.localdomain>
	 <20070721.115428.48807536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42050 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbXGUXKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 19:10:44 -0400
In-Reply-To: <20070721.115428.48807536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-07-21 at 11:54 -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Sat, 21 Jul 2007 18:00:11 +1000
> 
> > No, I was just thinking that drivers will put the napi_struct in their
> > driver-specific struct (eg. struct e1000_adapter *adapter =
> > container_of(container_of(napi, struct e1000_adapter, napi);).  
> 
> That works.
> 
> > Multi-queue drivers will have no use for a napi_struct in net_device,
> > right?  They'll need some wrapper "my_queue" structure containing the
> > napi_struct anyway.
> 
> Sure, we can eliminate the napi_struct in struct net_device
> eventually.
> 
> But then again, like the statistics, if it's convenient to
> just use the in-net_device one then why not :)

Because *every* single driver can use the in-net_device stats.

In five years' time, the "napi_struct for simple drivers" in net_device
will look confusing.  Since your change touches all NAPI drivers anyway,
it'd be nice to go straight to "everyone allocates their own NAPI
struct" in one jump.

Cheers,
Rusty.


