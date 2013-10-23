From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: fix ASCONF to allow non SCTP_ADDR_SRC
 addresses in ipv6
Date: Wed, 23 Oct 2013 07:36:36 -0400
Message-ID: <20131023113636.GB21456@hmsreliant.think-freely.org>
References: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Michio Honda <micchie@sfc.wide.ad.jp>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60705 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938Ab3JWLgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 07:36:42 -0400
Content-Disposition: inline
In-Reply-To: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 22, 2013 at 06:34:56PM +0200, Daniel Borkmann wrote:
> Commit 8a07eb0a50 ("sctp: Add ASCONF operation on the single-homed host")
> implemented possible use of IPv4 addresses with non SCTP_ADDR_SRC state
> as source address when sending ASCONF (ADD) packets, but IPv6 part for
> that was not implemented in 8a07eb0a50. Therefore, as this is not restricted
> to IPv4-only, fix this up to allow the same for IPv6 addresses in SCTP.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
>  net/sctp/ipv6.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index e7b2d4f..96a5591 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -279,7 +279,9 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>  		sctp_v6_to_addr(&dst_saddr, &fl6->saddr, htons(bp->port));
>  		rcu_read_lock();
>  		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> -			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
> +			if (!laddr->valid || laddr->state == SCTP_ADDR_DEL ||
> +			    (laddr->state != SCTP_ADDR_SRC &&
> +			     !asoc->src_out_of_asoc_ok))
>  				continue;
>  
>  			/* Do not compare against v4 addrs */
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
