From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][RFC] TSO for VLAN devices without VLAN tag insertion
Date: Thu, 12 Jun 2008 14:02:13 +0200
Message-ID: <48511045.8080805@trash.net>
References: <20080610195943.GO11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37880 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbYFLMCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 08:02:19 -0400
In-Reply-To: <20080610195943.GO11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> The SFC4000 controller can set IP header, TCP and UDP checksums in IPv4
> packets, with or without VLAN encapsulation.  However it does not do VLAN
> tag insertion.
> 
> When I try to make TSO work for VLAN devices via the new vlan_features,
> dev_queue_xmit() finds skb->ip_summed == CHECKSUM_PARTIAL &&
> skb->protocol == htons(ETH_P_8021Q) and calls skb_checksum_help(), which
> sets skb->ip_summed = CHECKSUM_NONE.
> 
> This causes netif_needs_gso() to return true when called by
> dev_hard_start_xmit(), and GSO then does its worst.
> 
> Below is a patch which worked for me, but I'm not sure whether it's the
> best way to fix the problem (so I'm not submitting or signing it off yet).


It looks reasonable - I can't think of a different way to handle
this case, although its a bit unfortunate that we have to put this
in dev_queue_xmit().
