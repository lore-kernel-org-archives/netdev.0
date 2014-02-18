From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch] af_packet: remove a stray tab in packet_set_ring()
Date: Tue, 18 Feb 2014 16:52:15 +0100
Message-ID: <530381AF.7090409@redhat.com>
References: <20140218122050.GB9604@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, Phil Sutter <phil@nwl.cc>,
	Atzm Watanabe <atzm@stratosphere.co.jp>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35265 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755593AbaBRPwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 10:52:54 -0500
In-Reply-To: <20140218122050.GB9604@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2014 01:20 PM, Dan Carpenter wrote:
> At first glance it looks like there is a missing curly brace but
> actually the code works the same either way.  I have adjusted the
> indenting but left the code the same.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Agreed.

Actually, this whole construct could have been simplified ...

     switch (po->tp_version) {
     case TPACKET_V3:
     /* Transmit path is not supported. We checked
      * it above but just being paranoid
      */
         if (!tx_ring)
             init_prb_bdqc(po, rb, pg_vec, req_u, tx_ring);
             break;
     default:
         break;
     }

... into just one if condition. Looks a bit unnecessary as
there's just one case. Feel free to change that as well.

Otherwise ...

Acked-by: Daniel Borkmann <dborkman@redhat.com>

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 6a2bb37506c5..7fd37de503d1 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -3786,7 +3786,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>   		 */
>   			if (!tx_ring)
>   				init_prb_bdqc(po, rb, pg_vec, req_u, tx_ring);
> -				break;
> +			break;
>   		default:
>   			break;
>   		}
>
