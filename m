From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v1 net] packet: handle too big packets for PACKET_V3
Date: Mon, 18 Aug 2014 17:39:02 +0200
Message-ID: <53F21E16.1090706@redhat.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>  <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>  <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>  <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>  <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>  <0B7AA838-0FC7-4B0C-881E-17FC71748140@alum.mit.edu> <1408119364.6804.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev <netdev@vger.kernel.org>, Guy Harris <guy@alum.mit.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789AbaHRPjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 11:39:21 -0400
In-Reply-To: <1408119364.6804.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2014 06:16 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> af_packet can currently overwrite kernel memory by out of bound
> accesses, because it assumed a [new] block can always hold one frame.
>
> This is not generally the case, even if most existing tools do it right.
>
> This patch clamps too long frames as API permits, and issue a one time
> error on syslog.
>
> [  394.357639] tpacket_rcv: packet too big, clamped from 5042 to 3966. macoff=82
>
> In this example, packet header tp_snaplen was set to 3966,
> and tp_len was set to 5042 (skb->len)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation.")

Acked-by: Daniel Borkmann <dborkman@redhat.com>

This looks good to me, thanks Eric!

[ Truly dislike the TPACKET_V3 code ... :/ ]
