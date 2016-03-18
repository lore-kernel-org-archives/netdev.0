From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: keep fragmentation point aligned to word size
Date: Fri, 18 Mar 2016 20:11:04 -0300
Message-ID: <20160318231104.GD3387@mrl.redhat.com>
References: <1458337159-22792-2-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40035 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859AbcCRXLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 19:11:08 -0400
Content-Disposition: inline
In-Reply-To: <1458337159-22792-2-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 06:39:17PM -0300, Marcelo Ricardo Leitner wrote:
> If the user supply a different fragmentation point or if there is a
> network header that cause it to not be aligned, force it to be aligned.
> 
> Fragmentation point at a value that is not aligned is not optimal.  It
> causes extra padding to be used and has just no pros.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  include/net/sctp/sctp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 835aa2ed987092634a4242314e9eabb51d1e4e35..f27d38113c7926783a9bf2863e14e963ed0ad5d6 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -426,7 +426,7 @@ static inline int sctp_frag_point(const struct sctp_association *asoc, int pmtu)
>  	if (asoc->user_frag)
>  		frag = min_t(int, frag, asoc->user_frag);
>  
> -	frag = min_t(int, frag, SCTP_MAX_CHUNK_LEN);
> +	frag = min_t(int, frag, SCTP_MAX_CHUNK_LEN) & ~3;

Will submit a v2 with a helper for this & ~3 thing
