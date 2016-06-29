From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv4: Fix ip_skb_dst_mtu to use the sk passed by
 ip_finish_output
Date: Wed, 29 Jun 2016 23:42:06 +0200
Message-ID: <1467236526.2907671.652444929.21883A96@webmail.messagingengine.com>
References: <1467226023-4168-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Zhou <azhou@ovn.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48490 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbcF2VmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:42:08 -0400
In-Reply-To: <1467226023-4168-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016, at 20:47, Shmulik Ladkani wrote:
> ip_skb_dst_mtu uses skb->sk, assuming it is an AF_INET socket (e.g. it
> calls ip_sk_use_pmtu which casts sk as an inet_sk).
> 
> However, in the case of UDP tunneling, the skb->sk is not necessarily an
> inet socket (could be AF_PACKET socket, or AF_UNSPEC if arriving from
> tun/tap).
> 
> OTOH, the sk passed as an argument throughout IP stack's output path is
> the one which is of PMTU interest:
>  - In case of local sockets, sk is same as skb->sk;
>  - In case of a udp tunnel, sk is the tunneling socket.
> 
> Fix, by passing ip_finish_output's sk to ip_skb_dst_mtu.
> This augments 7026b1ddb6 'netfilter: Pass socket pointer down through
> okfn().'
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---
> 
> Discovered while debugging other issue in adjacent code area.
> 
> My setup seems to be handling this well; However I'd appreciate a
> Tested-by or Reviewed-by as one can only cover relatively few of the
> possible code flows leading to ip_skb_dst_mtu.

Well spotted.

It all looks good, the socket's pmtudisc field is initialized
accordingly and I suspect people want to have vxlan to use the path mtu
when transmitting packets, even during forwarding.

Maybe this can be tweaked with an additional patch, if people want to
change this behavior.

But as your patch doesn't change any of this,

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
