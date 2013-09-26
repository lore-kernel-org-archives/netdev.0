From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: flow_dissector: fix thoff for IPPROTO_AH
Date: Thu, 26 Sep 2013 18:03:37 +0200
Message-ID: <52445AD9.9060208@redhat.com>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>  <1380204582-27144-2-git-send-email-nikolay@redhat.com>  <1380209227.3165.176.camel@edumazet-glaptop> <1380210246.3165.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab3IZQDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 12:03:45 -0400
In-Reply-To: <1380210246.3165.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2013 05:44 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In commit 8ed781668dd49 ("flow_keys: include thoff into flow_keys for
> later usage"), we missed that existing code was using nhoff as a
> temporary variable that could not always contain transport header
> offset.
>
> This is not a problem for TCP/UDP because port offset (@poff)
> is 0 for these protocols.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Nikolay Aleksandrov <nikolay@redhat.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

Thanks !

> ---
>   net/core/flow_dissector.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 1929af8..8d7d0dd 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -154,8 +154,8 @@ ipv6:
>   	if (poff >= 0) {
>   		__be32 *ports, _ports;
>
> -		nhoff += poff;
> -		ports = skb_header_pointer(skb, nhoff, sizeof(_ports), &_ports);
> +		ports = skb_header_pointer(skb, nhoff + poff,
> +					   sizeof(_ports), &_ports);
>   		if (ports)
>   			flow->ports = *ports;
>   	}
>
>
