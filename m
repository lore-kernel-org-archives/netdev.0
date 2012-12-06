From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Fix compiler warning when
 CONFIG_DEBUG_SECTION_MISMATCH=y
Date: Thu, 6 Dec 2012 09:11:59 -0500
Message-ID: <20121206141159.GB17192@hmsreliant.think-freely.org>
References: <1354798992-25622-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	davem@davemloft.net, sri@us.ibm.com, netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51598 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab2LFOMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 09:12:13 -0500
Content-Disposition: inline
In-Reply-To: <1354798992-25622-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 06, 2012 at 02:03:12PM +0100, Christoph Paasch wrote:
> WARNING: net/sctp/sctp.o(.text+0x72f1): Section mismatch in reference
> from the function sctp_net_init() to the function
> .init.text:sctp_proc_init()
> The function sctp_net_init() references
> the function __init sctp_proc_init().
> This is often because sctp_net_init lacks a __init
> annotation or the annotation of sctp_proc_init is wrong.
> 
> And put __net_init after 'int' for sctp_proc_init - as it is done
> everywhere else in the sctp-stack.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/sctp/protocol.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 456bc3d..2c7785b 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -86,7 +86,7 @@ int sysctl_sctp_rmem[3];
>  int sysctl_sctp_wmem[3];
>  
>  /* Set up the proc fs entry for the SCTP protocol. */
> -static __net_init int sctp_proc_init(struct net *net)
> +static int __net_init sctp_proc_init(struct net *net)
>  {
>  #ifdef CONFIG_PROC_FS
>  	net->sctp.proc_net_sctp = proc_net_mkdir(net, "sctp", net->proc_net);
> @@ -1165,7 +1165,7 @@ static void sctp_v4_del_protocol(void)
>  	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
>  }
>  
> -static int sctp_net_init(struct net *net)
> +static int __net_init sctp_net_init(struct net *net)
>  {
>  	int status;
>  
> @@ -1290,7 +1290,7 @@ err_sysctl_register:
>  	return status;
>  }
>  
> -static void sctp_net_exit(struct net *net)
> +static void __net_exit sctp_net_exit(struct net *net)
>  {
>  	/* Free the local address list */
>  	sctp_free_addr_wq(net);
> -- 
> 1.7.10.4
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
