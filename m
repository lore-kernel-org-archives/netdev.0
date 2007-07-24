From: Brian Haley <brian.haley@hp.com>
Subject: Re: [GENETLINK]: Fix race in genl_unregister_mc_groups()
Date: Tue, 24 Jul 2007 12:14:28 -0400
Message-ID: <46A62564.3070006@hp.com>
References: <20070724094557.GE9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:54428 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752651AbXGXQbw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 12:31:52 -0400
In-Reply-To: <20070724094557.GE9285@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> @@ -217,14 +229,8 @@ EXPORT_SYMBOL(genl_register_mc_group);
>  void genl_unregister_mc_group(struct genl_family *family,
>  			      struct genl_multicast_group *grp)
>  {
> -	BUG_ON(grp->family != family);
>  	genl_lock();
> -	netlink_clear_multicast_users(genl_sock, grp->id);
> -	clear_bit(grp->id, mc_groups);
> -	list_del(&grp->list);
> -	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
> -	grp->id = 0;
> -	grp->family = NULL;
> +	genl_unregister_mc_group(family, grp);
>  	genl_unlock();
>  }

Shouldn't this be __genl_unregister_mc_group(family, grp) ?

-Brian
