From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: fix error return code in
 sctp_send_add_streams()
Date: Tue, 31 Oct 2017 13:06:36 -0400
Message-ID: <20171031170636.GA3230@hmswarspite.think-freely.org>
References: <1509456496-93944-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyongjun1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42888 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752177AbdJaRHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:07:33 -0400
Content-Disposition: inline
In-Reply-To: <1509456496-93944-1-git-send-email-weiyongjun1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 01:28:16PM +0000, Wei Yongjun wrote:
> Fix to returnerror code -ENOMEM from the sctp_make_strreset_addstrm()
> error handling case instead of 0. 'retval' can be overwritten to 0 after
> call sctp_stream_alloc_out().
> 
> Fixes: e090abd0d81c ("sctp: factor out stream->out allocation")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> ---
>  net/sctp/stream.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/stream.c b/net/sctp/stream.c
> index 03764fc..b8c8cab 100644
> --- a/net/sctp/stream.c
> +++ b/net/sctp/stream.c
> @@ -393,7 +393,7 @@ int sctp_send_add_streams(struct sctp_association *asoc,
>  {
>  	struct sctp_stream *stream = &asoc->stream;
>  	struct sctp_chunk *chunk = NULL;
> -	int retval = -ENOMEM;
> +	int retval;
>  	__u32 outcnt, incnt;
>  	__u16 out, in;
>  
> @@ -425,8 +425,10 @@ int sctp_send_add_streams(struct sctp_association *asoc,
>  	}
>  
>  	chunk = sctp_make_strreset_addstrm(asoc, out, in);
> -	if (!chunk)
> +	if (!chunk) {
> +		retval = -ENOMEM;
>  		goto out;
> +	}
>  
>  	asoc->strreset_chunk = chunk;
>  	sctp_chunk_hold(asoc->strreset_chunk);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
