From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v3 net-next 5/7] sctp: prepare for socket backlog
 behavior change
Date: Fri, 29 Apr 2016 19:01:47 -0300
Message-ID: <20160429220147.GA6672@localhost.localdomain>
References: <1461964613-4872-1-git-send-email-edumazet@google.com>
 <1461964613-4872-6-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Alexei Starovoitov <ast@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbcD2WBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2016 18:01:51 -0400
Content-Disposition: inline
In-Reply-To: <1461964613-4872-6-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 02:16:51PM -0700, Eric Dumazet wrote:
> sctp_inq_push() will soon be called without BH being blocked
> when generic socket code flushes the socket backlog.
> 
> It is very possible SCTP can be converted to not rely on BH,
> but this needs to be done by SCTP experts.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Thanks

> ---
>  net/sctp/inqueue.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
> index b335ffcef0b9..9d87bba0ff1d 100644
> --- a/net/sctp/inqueue.c
> +++ b/net/sctp/inqueue.c
> @@ -89,10 +89,12 @@ void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
>  	 * Eventually, we should clean up inqueue to not rely
>  	 * on the BH related data structures.
>  	 */
> +	local_bh_disable();
>  	list_add_tail(&chunk->list, &q->in_chunk_list);
>  	if (chunk->asoc)
>  		chunk->asoc->stats.ipackets++;
>  	q->immediate.func(&q->immediate);
> +	local_bh_enable();
>  }
>  
>  /* Peek at the next chunk on the inqeue. */
> -- 
> 2.8.0.rc3.226.g39d4020
> 
