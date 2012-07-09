From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] ksz884x: fix Endian
Date: Sun, 08 Jul 2012 22:44:56 -0700
Message-ID: <1341812696.13174.46.camel@joe2Laptop>
References: <1341454003-11227-1-git-send-email-roy.qing.li@gmail.com>
	 <1341614416.2923.12.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAJFZqHzm7=-PpsiNZJ9TgkDY2bt5WW7XwY6nBOa_E4eerRh1pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Tristram.Ha@micrel.com
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46570 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751073Ab2GIFo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2012 01:44:57 -0400
In-Reply-To: <CAJFZqHzm7=-PpsiNZJ9TgkDY2bt5WW7XwY6nBOa_E4eerRh1pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 13:26 +0800, RongQing Li wrote:
> 2012/7/7, Ben Hutchings <bhutchings@solarflare.com>:
> > On Thu, 2012-07-05 at 10:06 +0800, roy.qing.li@gmail.com wrote:
> >> ETH_P_IP is host Endian, skb->protocol is big Endian, when
> >> compare them, we should change skb->protocol from big endian
> >> to host endian, ntohs, not htons.
[]
> >> diff --git a/drivers/net/ethernet/micrel/ksz884x.c
[]
> >> @@ -4882,7 +4882,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb,
> >> struct net_device *dev)
> >>  	if (left) {
> >>  		if (left < num ||
> >>  				((CHECKSUM_PARTIAL == skb->ip_summed) &&
> >> -				(ETH_P_IPV6 == htons(skb->protocol)))) {
> >> +				(ETH_P_IPV6 == ntohs(skb->protocol)))) {
> >
> > This should really be changed to the idiomatic 'skb->protocol ==
> > htons(ETH_P_IPV6)'.  For the current code, the compiler will probably
> > generate a run-time byte-swap for little-endian systems.

True.  Perhaps this would be better written as:

	if (left) {
		if (left < num ||
		    (ip->ip_summed == CHECKSUM_PARTIAL &&
		     skb->protocol == htons(ETH_P_IPV6))) {

			etc...
