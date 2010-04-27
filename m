From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [patch v2] sctp: cleanup: remove duplicate assignment
Date: Tue, 27 Apr 2010 10:32:34 -0400
Message-ID: <4BD6F582.9030804@hp.com>
References: <20100423115906.GE29093@bicker> <4BD1AE9D.6090807@hp.com> <20100424171805.GO29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Chris Dischino <cdischino@sonusnet.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:28737 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab0D0Oci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 10:32:38 -0400
In-Reply-To: <20100424171805.GO29093@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Carpenter wrote:
> This assignment isn't needed because we did it earlier already.
> 
> Also another reason to delete the assignment is because it triggers a
> Smatch warning about checking for NULL pointers after a dereference.
> 
> Reported-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Thanks.  I'll take this one.

-vlad

> ---
> Thanks Vlad.  I came so close to seeing that myself if only I had openned
> my eyes a tiny bit more.  :P
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 17cb400..33aed1c 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -419,10 +419,17 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
>  	if (!retval)
>  		goto nomem_chunk;
>  
> -	/* Per the advice in RFC 2960 6.4, send this reply to
> -	 * the source of the INIT packet.
> +	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
> +	 *
> +	 * An endpoint SHOULD transmit reply chunks (e.g., SACK,
> +	 * HEARTBEAT ACK, * etc.) to the same destination transport
> +	 * address from which it received the DATA or control chunk
> +	 * to which it is replying.
> +	 *
> +	 * [INIT ACK back to where the INIT came from.]
>  	 */
>  	retval->transport = chunk->transport;
> +
>  	retval->subh.init_hdr =
>  		sctp_addto_chunk(retval, sizeof(initack), &initack);
>  	retval->param_hdr.v = sctp_addto_chunk(retval, addrs_len, addrs.v);
> @@ -461,18 +468,6 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
>  	/* We need to remove the const qualifier at this point.  */
>  	retval->asoc = (struct sctp_association *) asoc;
>  
> -	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
> -	 *
> -	 * An endpoint SHOULD transmit reply chunks (e.g., SACK,
> -	 * HEARTBEAT ACK, * etc.) to the same destination transport
> -	 * address from which it received the DATA or control chunk
> -	 * to which it is replying.
> -	 *
> -	 * [INIT ACK back to where the INIT came from.]
> -	 */
> -	if (chunk)
> -		retval->transport = chunk->transport;
> -
>  nomem_chunk:
>  	kfree(cookie);
>  nomem_cookie:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
