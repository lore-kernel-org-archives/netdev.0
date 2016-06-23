From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] ipv6: allows gracefull fallback from table lookup
Date: Thu, 23 Jun 2016 15:17:27 +0200
Message-ID: <1466687847.4910.34.camel@redhat.com>
References: <5c8a767f13a1c929f22b8c9ff098ae00ba12100a.1466687246.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Beniamino Galvani <bgalvani@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbcFWNRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 09:17:30 -0400
In-Reply-To: <5c8a767f13a1c929f22b8c9ff098ae00ba12100a.1466687246.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-23 at 15:11 +0200, Paolo Abeni wrote:
> with the commit 8c14586fc320 ("net: ipv6: Use passed in table for
> nexthop lookups"), net hop lookup is first performed on route creation
> in the passed-in table.
> However device match is not enforced in table lookup, so the found
> route can be later discarded due to egress device mismatch and no
> global lookup will be performed.
> This cause the following to fail:
> 
> ip link add dummy1 type dummy
> ip link add dummy2 type dummy
> ip link set dummy1 up
> ip link set dummy2 up
> ip route add 2001:db8:8086::/48 dev dummy1 metric 20
> ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy1 metric 20
> ip route add 2001:db8:8086::/48 dev dummy2 metric 21
> ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy2 metric 21
> RTNETLINK answers: No route to host
> 
> This change fixes the issue enforcing device lookup in
> ip6_nh_lookup_table()
> 
> Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
> Reported-and-tested-by: Beniamino Galvani <bgalvani@redhat.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Oops, bad commit message title (not updated from a previous
implementation), I'll resubmit with a more relevant one. Sorry for the
noise.

Paolo
