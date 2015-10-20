From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] ipv6: don't use CHECKSUM_PARTIAL on MSG_MORE/UDP_CORK
 sockets
Date: Tue, 20 Oct 2015 10:55:40 -0400
Message-ID: <562655EC.6060107@gmail.com>
References: <1445351922-8463-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sd@quesysnail.net, bcodding@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33201 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbbJTOzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 10:55:42 -0400
Received: by qgeo38 with SMTP id o38so17225807qge.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 07:55:42 -0700 (PDT)
In-Reply-To: <1445351922-8463-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2015 10:38 AM, Hannes Frederic Sowa wrote:
> MSG_MORE might cause the packet to get fragmented in the end when
> passed down to the flush function and the transhdrlen check alone is
> not sufficient to protect against fragmentation. Instead check if the
> socket user intends to add more data to the socket on the first packet.
> 
> This broke checksum calculation for UDPv6 for NFS protocols.
> 
> Fixes: 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
> Cc: Vlad Yasevich <vyasevich@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> Tested-by: Sabrina Dubroca <sd@quesysnail.net>
> Tested-by: Benjamin Coddington <bcodding@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_output.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 61d403e..95c5780 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1317,6 +1317,7 @@ emsgsize:
>  	 * sums only work when transhdrlen is set.
>  	 */
>  	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
> +	    !(flags & MSG_MORE) &&
>  	    length + fragheaderlen < mtu &&
>  	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
>  	    !exthdrlen)
> 
