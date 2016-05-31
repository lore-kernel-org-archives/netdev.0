From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2 net] sctp: sctp_diag should dump sctp socket type
Date: Tue, 31 May 2016 08:35:08 -0400
Message-ID: <20160531123508.GA6066@hmsreliant.think-freely.org>
References: <56c3ecedbc132e8501fd7cfbe056525155a1f915.1464514933.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	phil@nwl.cc
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44720 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbcEaMfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 08:35:25 -0400
Content-Disposition: inline
In-Reply-To: <56c3ecedbc132e8501fd7cfbe056525155a1f915.1464514933.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 29, 2016 at 05:42:13PM +0800, Xin Long wrote:
> Now we cannot distinguish that one sk is a udp or sctp style when
> we use ss to dump sctp_info. it's necessary to dump it as well.
> 
> For sctp_diag, ss support is not officially available, thus there
> are no official users of this yet, so we can add this field in the
> middle of sctp_info without breaking user API.
> 
> v1->v2:
>   - move 'sctpi_s_type' field to the end of struct sctp_info, so
>     that it won't cause incompatibility with applications already
>     built.
>   - add __reserved3 in sctp_info to make sure sctp_info is 8-byte
>     alignment.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/linux/sctp.h | 2 ++
>  net/sctp/socket.c    | 1 +
>  2 files changed, 3 insertions(+)
> 
> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index dacb5e7..de1f643 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -765,6 +765,8 @@ struct sctp_info {
>  	__u8	sctpi_s_disable_fragments;
>  	__u8	sctpi_s_v4mapped;
>  	__u8	sctpi_s_frag_interleave;
> +	__u32	sctpi_s_type;
> +	__u32	__reserved3;
>  };
>  
>  struct sctp_infox {
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 777d032..67154b8 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4220,6 +4220,7 @@ int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
>  		info->sctpi_s_disable_fragments = sp->disable_fragments;
>  		info->sctpi_s_v4mapped = sp->v4mapped;
>  		info->sctpi_s_frag_interleave = sp->frag_interleave;
> +		info->sctpi_s_type = sp->type;
>  
>  		return 0;
>  	}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
