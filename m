From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next 2/2] xfrm: configure policy hash table
 thresholds by /proc
Date: Thu, 15 May 2014 10:34:47 +0200
Message-ID: <20140515083447.GC32371@secunet.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
 <1399902325-1788-3-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46605 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbaEOIe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 04:34:58 -0400
Content-Disposition: inline
In-Reply-To: <1399902325-1788-3-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 03:45:25PM +0200, Christophe Gouault wrote:
> Enable to specify local and remote prefix length thresholds
> for the policy hash table via /proc entries. Example:
> 
> echo 0 24 > /proc/sys/net/ipv4/xfrm4_policy_hash_tresh
> echo 0 56 > /proc/sys/net/ipv6/xfrm6_policy_hash_tresh

I would not like to have this configurable from userspace.
Fist of all, a good threshold depends on the IPsec configuration
and can change during runtime. So it is not obvious for a user
which values are good for his configuration. Most users will
just leave the default, so they will not benefit from your
changes.

Second, on the long run we have to remove the IPsec flowcache
as this has the same limitation as our routing cache had.
To do this, we need to replace the hashlist based policy and
state lookups by a well performing lookup algorithm and I
would like to do that without any user visible changes.

Can't we tune the hash threshold internally? We could maintain
a per hashlist policy counter. If we have 'many' policies and
most of these policies are in the same hashlist we could change
the hash threshold. We could check this when we add policies
and update the hash threshold if needed.

Everything else looks pretty good, thanks!
