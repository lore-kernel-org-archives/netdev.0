From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 2/4] [RFC] Add c/r support for connected INET sockets
Date: Fri, 23 Oct 2009 15:37:48 -0400
Message-ID: <4AE2060C.5000903@librato.com>
References: <1256072803-3518-1-git-send-email-danms@us.ibm.com> <1256072803-3518-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	John Dykstra <jdykstra72@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp171.iad.emailsrvr.com ([207.97.245.171]:59532 "EHLO
	smtp171.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbZJWTho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 15:37:44 -0400
In-Reply-To: <1256072803-3518-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> This patch adds basic support for C/R of open INET sockets.  I think that
> all the important bits of the TCP and ICSK socket structures is saved,
> but I think there is still some additional IPv6 stuff that needs to be
> handled.
> 
> With this patch applied, the following script can be used to demonstrate
> the functionality:
> 
>   https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html
> 
> It shows that this enables migration of a sendmail process with open
> connections from one machine to another without dropping.
> 
> We still need comments from the netdev people about what sort of sanity
> checking we need to do on the values in the ckpt_hdr_socket_inet
> structure on restart.
> 
> Note that this still doesn't address lingering sockets yet.
> 

[...]

> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index fa57cdc..91c141b 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -65,6 +65,8 @@ struct ckpt_ctx {
>  	struct list_head pgarr_list;	/* page array to dump VMA contents */
>  	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
>  
> +	struct list_head listen_sockets;/* listening parent sockets */
> +

Nit: maybe move under the comment "multi-process restart" ?

[...]

Otherwise (and pending comments from netdev people on sanity checks):

Acked-by: Oren Laadan <orenl@cs.columbia.edu>

