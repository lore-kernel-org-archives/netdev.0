From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: fix error path in sctp_proc_init
Date: Tue, 17 Jun 2008 09:46:13 -0400
Message-ID: <4857C025.8010701@hp.com>
References: <4857AE19.9050708@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:3378 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686AbYFQNrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:47:03 -0400
In-Reply-To: <4857AE19.9050708@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> After the sctp_remaddr_proc_init failed, the proper rollback is
> not the sctp_remaddr_proc_exit, but the sctp_assocs_proc_exit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Ack for net-next-2.6.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad

> 
> ---
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 23aaffb..98c6a88 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -119,7 +119,7 @@ static __init int sctp_proc_init(void)
>  	return 0;
>  
>  out_remaddr_proc_init:
> -	sctp_remaddr_proc_exit();
> +	sctp_assocs_proc_exit();
>  out_assocs_proc_init:
>  	sctp_eps_proc_exit();
>  out_eps_proc_init:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

