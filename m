From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast
 addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 17:55:07 -0500
Message-ID: <20140107175507.fb543c70.billfink@mindspring.com>
References: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:53089 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753585AbaAGWz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 17:55:58 -0500
In-Reply-To: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  7 Jan 2014, Francois-Xavier Le Bail wrote:

> This change allows to follow a recommandation of RFC4942.
> 
> - Add "anycast_src_echo_reply" sysctl to control the use of anycast addresses
>   as source addresses for ICMPv6 echo reply. This sysctl is false by default
>   to preserve existing behavior.
> - Add inline check ipv6_anycast_destination().
> - Use them in icmpv6_echo_reply().
> 
> Reference:
> RFC4942 - IPv6 Transition/Coexistence Security Considerations
>    (http://tools.ietf.org/html/rfc4942#section-2.1.6)
> 
> 2.1.6. Anycast Traffic Identification and Security
> 
>    [...]
>    To avoid exposing knowledge about the internal structure of the
>    network, it is recommended that anycast servers now take advantage of
>    the ability to return responses with the anycast address as the
>    source address if possible.
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> ---
> v4: update Subject and Documentation, this work also with anycast addresses
>     created via API, not just with Subnet-Router anycast addresses.
> 
> v5: alternative way, replace ipv6_chk_acast_addr() test by
>     ipv6_anycast_destination() test.

Why is ICMPV6 Echo Reply special?  Can't the internal structure
of the network be divined from other ICMPv6 responses such as
Destination Unreachable, Time Exceeded (Hop Limit), and Parameter
Problem.

					-Bill
