From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: remove temporary variable confirm from
 sctp_packet_transmit
Date: Sat, 18 Mar 2017 15:05:07 -0400
Message-ID: <20170318190507.GA14004@neilslaptop.think-freely.org>
References: <a1bef2ad80e5a7338fc5c6786ea61835014b8c61.1489835542.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, ja@ssi.bg
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42515 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbdCRTF3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 15:05:29 -0400
Content-Disposition: inline
In-Reply-To: <a1bef2ad80e5a7338fc5c6786ea61835014b8c61.1489835542.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 07:12:22PM +0800, Xin Long wrote:
> Commit c86a773c7802 ("sctp: add dst_pending_confirm flag") introduced
> a temporary variable "confirm" in sctp_packet_transmit.
> 
> But it broke the rule that longer lines should be above shorter ones.
> Besides, this variable is not necessary, so this patch is to just
> remove it and use tp->dst_pending_confirm directly.
> 
> Fixes: c86a773c7802 ("sctp: add dst_pending_confirm flag")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/output.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 71ce6b9..1224421 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -546,7 +546,6 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  	struct sctp_association *asoc = tp->asoc;
>  	struct sctp_chunk *chunk, *tmp;
>  	int pkt_count, gso = 0;
> -	int confirm;
>  	struct dst_entry *dst;
>  	struct sk_buff *head;
>  	struct sctphdr *sh;
> @@ -625,13 +624,13 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  			asoc->peer.last_sent_to = tp;
>  	}
>  	head->ignore_df = packet->ipfragok;
> -	confirm = tp->dst_pending_confirm;
> -	if (confirm)
> +	if (tp->dst_pending_confirm)
>  		skb_set_dst_pending_confirm(head, 1);
>  	/* neighbour should be confirmed on successful transmission or
>  	 * positive error
>  	 */
> -	if (tp->af_specific->sctp_xmit(head, tp) >= 0 && confirm)
> +	if (tp->af_specific->sctp_xmit(head, tp) >= 0 &&
> +	    tp->dst_pending_confirm)
>  		tp->dst_pending_confirm = 0;
>  
>  out:
> -- 
> 2.1.0
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
