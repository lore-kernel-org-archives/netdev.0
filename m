From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3 1/2] sctp: compress bit-wide flags to a bitfield on
 sctp_sock
Date: Tue, 12 Apr 2016 15:50:26 -0400
Message-ID: <20160412195026.GA32240@hmsreliant.think-freely.org>
References: <cover.1460144373.git.marcelo.leitner@gmail.com>
 <1d6d26426e6f1eee2851aed47b77ffe8bc335210.1460144373.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Jakub Sitnicki <jkbs@redhat.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47213 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbcDLTut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 15:50:49 -0400
Content-Disposition: inline
In-Reply-To: <1d6d26426e6f1eee2851aed47b77ffe8bc335210.1460144373.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2016 at 04:41:27PM -0300, Marcelo Ricardo Leitner wrote:
> It wastes space and gets worse as we add new flags, so convert bit-wide
> flags to a bitfield.
> 
> Currently it already saves 4 bytes in sctp_sock, which are left as holes
> in it for now. The whole struct needs packing, which should be done in
> another patch.
> 
> Note that do_auto_asconf cannot be merged, as explained in the comment
> before it.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  include/net/sctp/structs.h | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 6df1ce7a411c548bda4163840a90578b6e1b4cfe..1a6a626904bba4223b7921bbb4be41c2550271a7 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -210,14 +210,14 @@ struct sctp_sock {
>  	int user_frag;
>  
>  	__u32 autoclose;
> -	__u8 nodelay;
> -	__u8 disable_fragments;
> -	__u8 v4mapped;
> -	__u8 frag_interleave;
>  	__u32 adaptation_ind;
>  	__u32 pd_point;
> -	__u8 recvrcvinfo;
> -	__u8 recvnxtinfo;
> +	__u16	nodelay:1,
> +		disable_fragments:1,
> +		v4mapped:1,
> +		frag_interleave:1,
> +		recvrcvinfo:1,
> +		recvnxtinfo:1;
>  
>  	atomic_t pd_mode;
>  	/* Receive to here while partial delivery is in effect. */
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

I've not run it myself, but this series looks reasonable

Acked-by: Neil Horman <nhorman@tuxdriver.com>
