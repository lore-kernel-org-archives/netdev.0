From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] net: SCTP NULL-pointer dereference problem description
 and fix
Date: Wed, 15 Sep 2010 16:44:24 +0800
Message-ID: <4C908768.4040502@cn.fujitsu.com>
References: <201009151003.17407.dreibh@iem.uni-due.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Martin Becke <martin.becke@uni-due.de>
To: Thomas Dreibholz <dreibh@iem.uni-due.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52002 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751666Ab0IOIs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 04:48:29 -0400
In-Reply-To: <201009151003.17407.dreibh@iem.uni-due.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Dreibholz wrote, at 09/15/2010 04:03 PM:
> sctp_assoc_update_retran_path() in net/sctp/associola.c may dereference a 
> NULL-pointer when compiled with SCTP_DEBUG option: t will be NULL if there is 
> no usable path for retransmission. SCTP_DEBUG_PRINTK_IPADDR() makes an access 
> to t->ipaddr.v4.sin_port, without checking t before. t==NULL => oops.
> 
> The patch below against 2.6.36-rc4 (git repository) simply ensures that t is 
> checked for not being set to NULL before calling SCTP_DEBUG_PRINTK_IPADDR().

This bug has been reported by WeiYongjun and fixed by vlad for several months.
About the details see .
http://marc.info/?l=linux-sctp&m=127359276009851&w=2

But this patch is still in vlad's net-next tree, not in main tree.
See the patch:
http://git.kernel.org/?p=linux/kernel/git/vxy/lksctp-dev.git;a=commit;h=eb1639d206320e6a09168d6dd77306eaf5f02582



> 
> 
> Signed-off-by: Thomas Dreibholz <dreibh@iem.uni-due.de>
> ---
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index e41feff..b2688a4 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1321,15 +1321,15 @@ void sctp_assoc_update_retran_path(struct 
> sctp_association *asoc)
>  		}
>  	}
> 
> -	if (t)
> +	if (t) {
>  		asoc->peer.retran_path = t;
> -
> -	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
> -				 " %p addr: ",
> -				 " port: %d\n",
> -				 asoc,
> -				 (&t->ipaddr),
> -				 ntohs(t->ipaddr.v4.sin_port));
> +		SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
> +					 " %p addr: ",
> +					 " port: %d\n",
> +					 asoc,
> +					 (&t->ipaddr),
> +					 ntohs(t->ipaddr.v4.sin_port));
> +	}
>  }
> 
>  /* Choose the transport for sending retransmit packet.  */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


-- 

Best Regards
-----
Shan Wei
