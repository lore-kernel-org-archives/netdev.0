From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: ipv6: why disable ipv6 on last address removal?
Date: Tue, 16 Feb 2010 16:28:59 +0100
Message-ID: <20100216152859.GC29736@midget.suse.cz>
References: <20091208192046.GA5649@midget.suse.cz>
 <20091208.125611.135547597.davem@davemloft.net>
 <4B1F5423.4070109@linux-ipv6.org>
 <20100104.224436.107234750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, jbohac@suse.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50976 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932265Ab0BPP3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 10:29:01 -0500
Content-Disposition: inline
In-Reply-To: <20100104.224436.107234750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2010 at 10:44:36PM -0800, David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Wed, 09 Dec 2009 16:39:15 +0900
> 
> > Well, AFAIK, it is basically ancient thing.
> > Some (rather new) paramters are exactly related bringing
> > up each interface.
> > 
> > Such parameters should be set _before_ it is brought up.
> > For now, people can do this using the "default" value.
> 
> I think we should retain inet6 device private structure after
> we allocate it the first time that an ipv6 action occurs for
> the device, exactly so that settings made earlier can be
> retained.

Good, this was what my patch is doing. I still think this is as
simple as:

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2185,7 +2185,7 @@ static int inet6_addr_del(struct net *net, int ifindex, struct in6_addr *pfx,
 			   disable IPv6 on this interface.
 			 */
 			if (idev->addr_list == NULL)
-				addrconf_ifdown(idev->dev, 1);
+				addrconf_ifdown(idev->dev, 0);
 			return 0;
 		}
 	}

It does the same thing as NETDEV_DOWN down instead of the current
NETDEV_UNREGISTER-like behaviour. Could this perhaps be tried in
-next?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

