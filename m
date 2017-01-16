From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: remove useless code from
 sctp_apply_peer_addr_params
Date: Mon, 16 Jan 2017 08:23:05 -0500
Message-ID: <20170116132305.GB30105@hmswarspite.think-freely.org>
References: <99bc9f227c4c857d2bb258391231231d46c1899d.1484336556.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42898 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdAPNYG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 08:24:06 -0500
Content-Disposition: inline
In-Reply-To: <99bc9f227c4c857d2bb258391231231d46c1899d.1484336556.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 06:31:15PM -0200, Marcelo Ricardo Leitner wrote:
> sctp_frag_point() doesn't store anything, and thus just calling it
> cannot do anything useful.
> 
> sctp_apply_peer_addr_params is only called by
> sctp_setsockopt_peer_addr_params. When operating on an asoc,
> sctp_setsockopt_peer_addr_params will call sctp_apply_peer_addr_params
> once for the asoc, and then once for each transport this asoc has,
> meaning that the frag_point will be recomputed when updating the
> transports and calling it when updating the asoc is not necessary.
> IOW, no action is needed here and we can remove this call.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/socket.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 318c6786d6539a301ac7b76d82a49a1af3818d10..635e0341269330187c78ba93a35689f5c5d6be02 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2430,7 +2430,6 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
>  			sctp_assoc_sync_pmtu(sctp_opt2sk(sp), asoc);
>  		} else if (asoc) {
>  			asoc->pathmtu = params->spp_pathmtu;
> -			sctp_frag_point(asoc, params->spp_pathmtu);
>  		} else {
>  			sp->pathmtu = params->spp_pathmtu;
>  		}
> -- 
> 2.9.3
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
