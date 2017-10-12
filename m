From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 06/18] tipc: improve destination linked list
Date: Thu, 12 Oct 2017 11:57:44 -0700 (PDT)
Message-ID: <20171012.115744.1462642148056780607.davem@davemloft.net>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
        <1507816959-31787-7-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdJLS5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 14:57:45 -0400
In-Reply-To: <1507816959-31787-7-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 12 Oct 2017 16:02:27 +0200

> @@ -259,19 +259,19 @@ static int tipc_rcast_xmit(struct net *net, struct sk_buff_head *pkts,
>  			   struct tipc_nlist *dests, u16 *cong_link_cnt)
>  {
>  	struct sk_buff_head _pkts;
> -	struct u32_item *n, *tmp;
> -	u32 dst, selector;
> +	struct tipc_dest *dst, *tmp;
> +	u32 dnode, selector;

Order local variables from longest to shortest line please.

> -bool u32_find(struct list_head *l, u32 value)
> +struct tipc_dest *tipc_dest_find(struct list_head *l, u32 node, u32 port)
>  {
> -	struct u32_item *item;
> +	struct tipc_dest *dst;
> +	u64 value = (u64)node << 32 | port;

Likewise.

> -bool u32_push(struct list_head *l, u32 value)
> +bool tipc_dest_push(struct list_head *l, u32 node, u32 port)
>  {
> -	struct u32_item *item;
> +	struct tipc_dest *dst;
> +	u64 value = (u64)node << 32 | port;

Likewise.

You're probably tired of hearing me say this, so I'll just ask that you
audit the rest of your patch series for this problem as well.

Thank you :-)
