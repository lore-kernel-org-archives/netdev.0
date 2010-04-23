From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [patch] sctp: cleanup: remove unneeded null check
Date: Fri, 23 Apr 2010 10:28:45 -0400
Message-ID: <4BD1AE9D.6090807@hp.com>
References: <20100423115906.GE29093@bicker>
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
Received: from g4t0014.houston.hp.com ([15.201.24.17]:26137 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab0DWO2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 10:28:48 -0400
In-Reply-To: <20100423115906.GE29093@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Carpenter wrote:
> "chunk" can never be null here.  We dereferenced it earlier in the
> function and also at the start of the function we passed it to 
> sctp_pack_cookie() which dereferences it.
> 
> This code has been around since the dawn of git history so if "chunk"
> were ever null someone would have complained about it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 17cb400..52352fc 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -470,8 +470,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
>  	 *
>  	 * [INIT ACK back to where the INIT came from.]
>  	 */
> -	if (chunk)
> -		retval->transport = chunk->transport;
> +	retval->transport = chunk->transport;
>  

Actually, this code can be completely removed as we already make this assignment
earlier:

        /* Per the advice in RFC 2960 6.4, send this reply to
         * the source of the INIT packet.
         */
        retval->transport = chunk->transport;
        retval->subh.init_hdr =
                sctp_addto_chunk(retval, sizeof(initack), &initack);

-vlad

>  nomem_chunk:
>  	kfree(cookie);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


