From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix the issue sctp requeue auth chunk
 incorrectly
Date: Sat, 30 Jul 2016 10:21:13 -0300
Message-ID: <20160730132113.GA2957@localhost.localdomain>
References: <af1555c524101278be2e5b07ff78a1eaacc0f7bb.1469858315.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
	daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbcG3NVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2016 09:21:18 -0400
Content-Disposition: inline
In-Reply-To: <af1555c524101278be2e5b07ff78a1eaacc0f7bb.1469858315.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2016 at 01:58:35PM +0800, Xin Long wrote:
> sctp needs to queue auth chunk back when we know that we are going
> to generate another segment. But commit f1533cce60d1 ("sctp: fix
> panic when sending auth chunks") requeues the last chunk processed
> which is probably not the auth chunk.
> 
> It causes panic when calculating the MAC in sctp_auth_calculate_hmac(),
> as the incorrect offset of the auth chunk in skb->data.
> 
> This fix is to requeue it by using packet->auth.
> 
> Fixes: f1533cce60d1 ("sctp: fix panic when sending auth chunks")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/output.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 7425f6c..1f1682b 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -610,7 +610,8 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  				/* We will generate more packets, so re-queue
>  				 * auth chunk.
>  				 */
> -				list_add(&chunk->list, &packet->chunk_list);
> +				list_add(&packet->auth->list,
> +					 &packet->chunk_list);
>  			} else {
>  				sctp_chunk_free(packet->auth);
>  				packet->auth = NULL;
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
