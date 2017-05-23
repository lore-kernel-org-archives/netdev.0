From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 1/2] sctp: fix stream update when processing dupcookie
Date: Tue, 23 May 2017 12:26:46 -0400
Message-ID: <3f0e02fb-322c-8949-c7c2-0f6b7582baa5@redhat.com>
References: <cover.1495517205.git.lucien.xin@gmail.com>
 <132661a3448bf87e944c07860305d979bc4d5518.1495517205.git.lucien.xin@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750928AbdEWQ0t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 12:26:49 -0400
In-Reply-To: <132661a3448bf87e944c07860305d979bc4d5518.1495517205.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 01:28 AM, Xin Long wrote:
> Since commit 3dbcc105d556 ("sctp: alloc stream info when initializing
> asoc"), stream and stream.out info are always alloced when creating
> an asoc.
> 
> So it's not correct to check !asoc->stream before updating stream
> info when processing dupcookie, but would be better to check asoc
> state instead.
> 
> Fixes: 3dbcc105d556 ("sctp: alloc stream info when initializing asoc")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/associola.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index a9708da..9523828 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1176,7 +1176,9 @@ void sctp_assoc_update(struct sctp_association *asoc,
>  
>  		asoc->ctsn_ack_point = asoc->next_tsn - 1;
>  		asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
> -		if (!asoc->stream) {
> +
> +		if (sctp_state(asoc, COOKIE_WAIT)) {
> +			sctp_stream_free(asoc->stream);
>  			asoc->stream = new->stream;
>  			new->stream = NULL;
>  		}
> 
