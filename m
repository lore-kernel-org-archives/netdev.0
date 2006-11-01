From: walter harms <wharms@bfs.de>
Subject: Re: [KJ] [patch] net/tipc: sprintf/strcpy conversion
Date: Wed, 01 Nov 2006 22:38:26 +0100
Message-ID: <454913D2.9050608@bfs.de>
References: <20061101140624.GA7694@Chamillionaire.breakpoint.cc>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.fr.bfs.de ([194.95.226.137]:46563 "EHLO mail.fr.bfs.de")
	by vger.kernel.org with ESMTP id S1752461AbWKAVib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 16:38:31 -0500
To: kernel-janitors@lists.osdl.org,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
In-Reply-To: <20061101140624.GA7694@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


hi Florian,

These line
+	strcpy(bcbearer->media.name, "tipc-multicast");

i gues that means tipc_bclink_name ?
an even more secure version could be like this:

	strncpy(bcbearer->media.name,sizeof(bcbearer->media.name),tipc_bclink_name);

(in case someone ever changes the size of cbearer->media.name or tipc_bclink_name and the hope
that wchat_t will never reach the kernel)

re,
 wh




Florian Westphal wrote:
> From: Florian Westphal <fw@strlen.de>
> 
> convert sprintf(a,b) to strcpy(a,b). Make tipc_bclink_name[] const.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> ---
> 
> compile tested; diffed against davem/net-2.6.
> 
> --- a/net/tipc/bcast.c
> +++ b/net/tipc/bcast.c
> @@ -119,7 +119,7 @@ static struct bclink *bclink = NULL;
>  static struct link *bcl = NULL;
>  static DEFINE_SPINLOCK(bc_lock);
>  
> -char tipc_bclink_name[] = "multicast-link";
> +const char tipc_bclink_name[] = "multicast-link";
>  
>  
>  static u32 buf_seqno(struct sk_buff *buf)
> @@ -790,7 +790,7 @@ int tipc_bclink_init(void)
>  	INIT_LIST_HEAD(&bcbearer->bearer.cong_links);
>  	bcbearer->bearer.media = &bcbearer->media;
>  	bcbearer->media.send_msg = tipc_bcbearer_send;
> -	sprintf(bcbearer->media.name, "tipc-multicast");
> +	strcpy(bcbearer->media.name, "tipc-multicast");
>  
>  	bcl = &bclink->link;
>  	memset(bclink, 0, sizeof(struct bclink));
> @@ -802,7 +802,7 @@ int tipc_bclink_init(void)
>  	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
>  	bcl->b_ptr = &bcbearer->bearer;
>  	bcl->state = WORKING_WORKING;
> -	sprintf(bcl->name, tipc_bclink_name);
> +	strcpy(bcl->name, tipc_bclink_name);
>  
>  	if (BCLINK_LOG_BUF_SIZE) {
>  		char *pb = kmalloc(BCLINK_LOG_BUF_SIZE, GFP_ATOMIC);
> diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
> --- a/net/tipc/bcast.h
> +++ b/net/tipc/bcast.h
> @@ -70,7 +70,7 @@ struct port_list {
>  
>  struct node;
>  
> -extern char tipc_bclink_name[];
> +extern const char tipc_bclink_name[];
>  
>  
>  /**
> --- a/net/tipc/node.c
> +++ b/net/tipc/node.c
> @@ -667,7 +667,7 @@ struct sk_buff *tipc_node_get_links(cons
>          link_info.dest = tipc_own_addr & 0xfffff00;
>  	link_info.dest = htonl(link_info.dest);
>          link_info.up = htonl(1);
> -        sprintf(link_info.str, tipc_bclink_name);
> +        strcpy(link_info.str, tipc_bclink_name);
>  	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
>  
>  	/* Add TLVs for any other links in scope */
> _______________________________________________
> Kernel-janitors mailing list
> Kernel-janitors@lists.osdl.org
> https://lists.osdl.org/mailman/listinfo/kernel-janitors
> 
> 
> 
