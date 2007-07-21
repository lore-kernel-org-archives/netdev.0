From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sat, 21 Jul 2007 18:00:11 +1000
Message-ID: <1185004811.6344.37.camel@localhost.localdomain>
References: <20070720.223129.59470764.davem@davemloft.net>
	 <1185002071.6344.21.camel@localhost.localdomain>
	 <20070721.004234.122616332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58477 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbXGUIAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 04:00:31 -0400
In-Reply-To: <20070721.004234.122616332.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-07-21 at 00:42 -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Sat, 21 Jul 2007 17:14:31 +1000
> 
> > 	This looks good!  It might be nice though to go further and remove the
> > internal napi_struct.  It's kind of a wart for multi-queue drivers which
> > are going to have their own array (or whatever).
> 
> I guess you're suggesting to pass in a "void *" cookie instead of the
> napi_struct?  You'd need to pass in a slot number or similar as well
> with that kind of idea, and then it starts to push the limits or
> worthwhileness.

No, I was just thinking that drivers will put the napi_struct in their
driver-specific struct (eg. struct e1000_adapter *adapter =
container_of(container_of(napi, struct e1000_adapter, napi);).  

Multi-queue drivers will have no use for a napi_struct in net_device,
right?  They'll need some wrapper "my_queue" structure containing the
napi_struct anyway.

Hope that clarifies,
Rusty.

