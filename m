From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Fri, 5 Apr 2013 11:46:29 +0200
Message-ID: <20130405094629.GV21448@secunet.com>
References: <1365088362-4318-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, dbaluta@ixiacom.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33638 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323Ab3DEJqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 05:46:31 -0400
Content-Disposition: inline
In-Reply-To: <1365088362-4318-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 04, 2013 at 05:12:42PM +0200, Nicolas Dichtel wrote:
> Commit bc8e4b954e46 (xfrm6: ensure to use the same dev when building a bundle)
> broke IPsec for IPv4 over IPv6 tunnels (because dev points to an IPv4 only
> interface, hence in6_dev_get(dev) returns NULL.

Can you give some informations on how to reproduce this? I'm running
interfamily tunnels on our testing environment and it seems to
work fine.

> 
> After looking again into commit 25ee3286dcbc ([IPSEC]: Merge common code into
> xfrm_bundle_create), it seems that previously we were using dev from the route,
> for both IPv4 and IPv6.

I think this was the right way. We need to attach the dev from the
corresponding route to the xdst.

> 
> In fact, xfrm_fill_dst() is called during a loop on chained dst, but dev points
> always to the same device.

The way we do it now can be problematic for tunnel in tunnel scenarios too.
We assign the dev from the first tunnel route to all the bundle entries,
this looks really wrong.

I think your patch is correct, but I want understand the breaking 
scenario first.

Thanks!
