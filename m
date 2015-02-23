From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v2 net] ipv6: addrconf: validate new MTU before applying
 it
Date: Tue, 24 Feb 2015 00:10:02 +0100
Message-ID: <20150223231002.GA32636@kria>
References: <463ebd12cf29ddcf17275bdde9fb629444a5fa5b.1424698335.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:63785 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812AbbBWXKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 18:10:06 -0500
Content-Disposition: inline
In-Reply-To: <463ebd12cf29ddcf17275bdde9fb629444a5fa5b.1424698335.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-23, 11:17:13 -0300, Marcelo Ricardo Leitner wrote:
> Currently we don't check if the new MTU is valid or not and this allows
> one to configure a smaller than minimum allowed by RFCs or even bigger
> than interface own MTU, which is a problem as it may lead to packet
> drops.
> 
> If you have a daemon like NetworkManager running, this may be exploited
> by remote attackers by forging RA packets with an invalid MTU, possibly
> leading to a DoS. (NetworkManager currently only validates for values
> too small, but not for too big ones.)
> 
> The fix is just to make sure the new value is valid. That is, between
> IPV6_MIN_MTU and interface's MTU.
> 
> Note that similar check is already performed at
> ndisc_router_discovery(), for when kernel itself parses the RA.
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> ---
> 
> Notes:
>     Sabrina, please feel free to add your Signed-off-by if you want.
>     
>     v1->v2, applied Sabrina's notes:
>        use proc_dointvec_minmax instead
>        protect against all and default cases, which don't have idev
>     
>     all and default are simply not used, so we are good to simply ignore the
>     max values for them. The default value actually comes from interface MTU
>     during creation.
> 
>  net/ipv6/addrconf.c | 17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>


Thanks Marcelo.

-- 
Sabrina
