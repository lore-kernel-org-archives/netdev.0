From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Wed, 29 Oct 2014 15:37:32 +0100
Message-ID: <1414593452.24008.22.camel@localhost>
References: <1414487474-18201-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ben@decadent.org.uk,
	lorenzo@google.com
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54889 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932909AbaJ2Ohe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 10:37:34 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 2551C20A95
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 10:37:34 -0400 (EDT)
In-Reply-To: <1414487474-18201-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-10-28 at 18:11 +0900, Erik Kline wrote:
> Add a sysctl that causes an interface's optimistic addresses
> to be considered equivalent to other non-deprecated addresses
> for source address selection purposes.  Preferred addresses
> will still take precedence over optimistic addresses, subject
> to other ranking in the source address selection algorithm.
> 
> This is useful where different interfaces are connected to
> different networks from different ISPs (e.g., a cell network
> and a home wifi network).
> 
> The current behaviour complies with RFC 3484/6724, and it
> makes sense if the host has only one interface, or has
> multiple interfaces on the same network (same or cooperating
> administrative domain(s), but not in the multiple distinct
> networks case.
> 
> For example, if a mobile device has an IPv6 address on an LTE
> network and then connects to IPv6-enabled wifi, while the wifi
> IPv6 address is undergoing DAD, IPv6 connections will try use
> the wifi default route with the LTE IPv6 address, and will get
> stuck until they time out.
> 
> Also, because optimistic nodes can receive frames, issue
> an RTM_NEWADDR as soon as DAD starts (with the IFA_F_OPTIMSTIC
> flag appropriately set).  A second RTM_NEWADDR is sent if DAD
> completes (the address flags have changed), otherwise an
> RTM_DELADDR is sent.
> 
> Also: add an entry in ip-sysctl.txt for optimistic_dad.
> 
> Signed-off-by: Erik Kline <ek@google.com>
> ---
>
> [...]
>  
> +static inline bool ipv6_use_optimistic_addr(struct inet6_dev *idev)
> +{
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +	return idev && idev->cnf.optimistic_dad && idev->cnf.use_optimistic;

Just a small nit: is this idev != NULL check necessary?

Otherwise:
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
