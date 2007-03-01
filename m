From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Thu, 01 Mar 2007 06:47:44 -0500
Message-ID: <1172749664.4857.40.camel@localhost>
References: <45E67B04.2060702@linux-foundation.org>
	 <20070228.232224.74746939.davem@davemloft.net>
	 <45E6802C.2090708@linux-foundation.org>
	 <20070228.233034.74746721.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	bridge@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:15530 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933251AbXCALrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 06:47:48 -0500
Received: by nz-out-0506.google.com with SMTP id s1so462854nze
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2007 03:47:47 -0800 (PST)
In-Reply-To: <20070228.233034.74746721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-28-02 at 23:30 -0800, David Miller wrote:

> That would be perfect for new applications.
> But we have to support all the old ones, so we're stuck
> providing correctly functioning AF_PACKET handling on
> all devices, sorry.
> 

It also breaks all the ingress tc code by making that change.

The two scenarios i see in respect to performance are:
- run a sniffer and you will see a substantial performance degradation
as the pps goes up.  There is no rocket science to that. This has
nothing to do with bridging and will happen still even if that patch
went in. 

- dont run any tap with the current codepath and you still see the
_substantial_ performance drop then we have an opportunity
to optimize. Not _by avoiding the code_ as in Stephens patch but by
tunning that tap code path. [For example, you should still see a _tiny_
performance degradation if you turned on TC actions on ingress at
compile time but had zero policies at run time - but that code path has
been reduce to a single compare]. 


> And in fact that effectively makes the new socket option
> pointless, since it doesn't buy us anything since we have
> to support the old stuff fully anyways.

agreed.

I have been tied up elsewhere so havent been following netdev closely:
There seem to be complaints of bridging performance going down in recent
kernels - or is that someone misconfiguring their drivers?

cheers,
jamal

