From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 16/17] calipso: Add validation of CALIPSO option.
Date: Tue, 22 Dec 2015 14:50:20 +0100
Message-ID: <5679551C.4000105@stressinduktion.org>
References: <1450784813-18304-17-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <pmoore@redhat.com>
To: Huw Davies <huw@codeweavers.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:40108 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751274AbbLVNuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 08:50:23 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id B2E9A20D09
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 08:50:22 -0500 (EST)
In-Reply-To: <1450784813-18304-17-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.12.2015 12:46, Huw Davies wrote:
>  
> +/* CALIPSO RFC 5570 */
> +
> +static bool ipv6_hop_calipso(struct sk_buff *skb, int optoff)
> +{
> +	const unsigned char *nh = skb_network_header(skb);
> +
> +	if (nh[optoff + 1] < 8)
> +		goto drop;
> +
> +	if (nh[optoff + 6] * 4 + 8 > nh[optoff + 1])
> +		goto drop;
> +
> +	if (!calipso_validate(skb, nh + optoff))
> +		goto drop;
> +
> +	return true;
> +
> +drop:
> +	kfree_skb(skb);
> +	return false;
> +}
> +

Formally, if an extension header could not be processed, the packet
should be discarded and an icmp error parameter extension should be
send. I think we shouldn't let those packets pass here.

Thanks,
Hannes
