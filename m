From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 02/08]: vlan: deliver packets received with VLAN acceleration to network taps
Date: Wed, 9 Jul 2008 13:35:21 +0100
Message-ID: <20080709123520.GK28029@solarflare.com>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain> <20080709120948.11669.98935.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:55175 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbYGIMfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:35:24 -0400
Content-Disposition: inline
In-Reply-To: <20080709120948.11669.98935.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> vlan: deliver packets received with VLAN acceleration to network taps
> 
> When VLAN header stripping is used, packets currently bypass packet
> sockets (and other network taps) completely. For locally existing
> VLANs, they appear directly on the VLAN device, for unknown VLANs
> they are silently dropped.
> 
> Add a new function netif_nit_deliver() to deliver incoming packets
> to all network interface taps and use it in __vlan_hwaccel_rx() to
> make VLAN packets visible on the underlying device.
[...]
> +/*
> + * 	netif_tap_deliver - deliver received packets to network taps
> + * 	@skb: buffer
> + *
> + * 	This function is used to deliver incoming packets to network
> + * 	taps. It should be used when the normal netif_receive_skb path
> + * 	is bypassed, for example because of VLAN acceleration.
> + */
> +void netif_nit_deliver(struct sk_buff *skb)
[...]

Is it supposed to be called netif_nit_deliver() or netif_tap_deliver()?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
