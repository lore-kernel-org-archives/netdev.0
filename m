From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Fri, 4 Nov 2016 09:48:02 -0400 (EDT)
Message-ID: <1292666010.97911366.1478267282598.JavaMail.zimbra@redhat.com>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com> <20161103094239.13ac8ac2@pixies> <274982955.93728733.1478178387534.JavaMail.zimbra@redhat.com> <20161104112409.6277b7b0@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com,
        hannes@stressinduktion.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:36458 "EHLO
        mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934360AbcKDNsP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 09:48:15 -0400
In-Reply-To: <20161104112409.6277b7b0@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Shmulik Ladkani" <shmulik.ladkani@gmail.com>
> To: "Lance Richardson" <lrichard@redhat.com>
> Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com, hannes@stressinduktion.org
> Sent: Friday, November 4, 2016 5:24:09 AM
> Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in ip_finish_output_gso()
> 
> Hi,
> 
> On Thu, 3 Nov 2016 09:06:27 -0400 (EDT) Lance Richardson
> <lrichard@redhat.com> wrote:
> > I'm not sure what could be added that would help, was there something
> > specific you had in mind?
> 
> How about something like this (preliminary, feel free to massage):
> 
> @@ -248,10 +248,16 @@ static int ip_finish_output_gso(struct net *net, struct
> sock *sk,
>  
>  	/* Slowpath -  GSO segment length is exceeding the dst MTU.
>  	 *
> -	 * This can happen in two cases:
> -	 * 1) TCP GRO packet, DF bit not set
> -	 * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
> -	 * from host network stack.
> +	 * This can happen in several cases:
> +	 *  - Forwarding of TCP GRO packet, DF bit not set
> +	 *  - Forwarding of skb arrived in a virtualization environment (from
> +	 *    virtio-net/vhost/tap) with TSO/GSO size set by other's network
> +	 *    stack
> +	 *  - Local GSO skb xmitted on an NETIF_F_TSO tunnel stacked over an
> +	 *    interface with a smaller mtu
> +	 *  - Arriving GRO skb (or GSO skb in a virtualized env) that gets L2
> +	 *    bridged to a NETIF_F_TSO tunnel stacked over an interface with an
> +	 *    insufficent mtu
>  	 */
>  	features = netif_skb_features(skb);
>  	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
> 

Thanks, that looks good to me. I can send a follow-up patch with this change,
if you like (there seems to be agreement that the original patch is OK).

   Lance
