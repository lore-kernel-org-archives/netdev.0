From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] ip-address: properly display zero IPv4 peer
 address
Date: Wed, 11 Nov 2015 12:34:02 +0100
Message-ID: <20151111113402.GQ26876@orbit.nwl.cc>
References: <1445502868-29474-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34919 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497AbbKKLeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 06:34:05 -0500
Content-Disposition: inline
In-Reply-To: <1445502868-29474-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 10:34:28AM +0200, Thomas Haller wrote:
> Kernel allows for zero IPv4 peer addresses (IFA_ADDRESS):
> 
>    ip address add 192.168.5.1 peer 0.0.0.0/24 dev dummy
> 
> which is distinct from a usual address like:
> 
>    ip address add 192.168.5.1/24 dev dummy
>    ip address add 192.168.5.1 peer 192.168.5.1/24 dev dummy
> 
> For IPv4, a missing IFA_ADDRESS attribute means that the peer
> is 0.0.0.0. See inet_fill_ifaddr(), which does:
> 
>   if ((ifa->ifa_address &&
>        nla_put_in_addr(skb, IFA_ADDRESS, ifa->ifa_address)) ||
> 
> Signed-off-by: Thomas Haller <thaller@redhat.com>

Acked-by: Phil Sutter <phil@nwl.cc>

I wonder why this is not the case for IPv6. What is the functional
effect of setting a zero peer with non-zero netmask?

Cheers, Phil
