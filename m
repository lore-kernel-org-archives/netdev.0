From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] net: Use IPv6 flow label in flow_dissector
Date: Mon, 28 Apr 2014 00:55:54 +0400
Message-ID: <535D6EDA.2050903@cogentembedded.com>
References: <alpine.DEB.2.02.1404261553060.15726@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:47906 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbaD0Uz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 16:55:57 -0400
Received: by mail-lb0-f171.google.com with SMTP id u14so1502168lbd.16
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 13:55:56 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1404261553060.15726@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/27/2014 03:00 AM, Tom Herbert wrote:

> This implements the receive side to support RFC6438 which is to
> use the flow label as an ECMP hash. If an IPv6 flow label is set
> in a packet we can use this as input for computing an l4-hash.
> There should be no need to parse any transport headers in this
> case.

> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>   net/core/flow_dissector.c | 16 ++++++++++++++++
>   1 file changed, 16 insertions(+)

> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 107ed12..1c37d7b 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
[...]
> @@ -89,6 +91,20 @@ ipv6:
>   		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
>   		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
>   		nhoff += sizeof(struct ipv6hdr);
> +
> +		if ((flow_label = ip6_flowlabel(iph))) {

    This wouldn't pass scripts/checkpatch.pl -- assignments shouldn't be 
enclosed into the *if* statement's parens.

> +			/*
> +			 * Awesome, IPv6 packet has a flow label so we can
> +			 * use that to represent the ports without any
> +			 * further dissection.
> +			 */

    Multi-line comments in the networking code should look this way:

/* bla
  * bla
  */

This is also an issue that scripts/checkpatch.pl would complain about...

WBR, Sergei
