From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] [NETLINK]: Ignore control messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 05:44:24 +0100
Message-ID: <4600B828.1050801@trash.net>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.885191779@lsx.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32985 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbXCUEoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 00:44:34 -0400
In-Reply-To: <20070321001900.885191779@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Changes netlink_rcv_skb() to skip netlink controll messages and don't
> pass them on to the message handler.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.22/net/netlink/af_netlink.c
> ===================================================================
> --- net-2.6.22.orig/net/netlink/af_netlink.c	2007-03-21 01:17:13.000000000 +0100
> +++ net-2.6.22/net/netlink/af_netlink.c	2007-03-21 01:17:46.000000000 +0100
> @@ -1479,6 +1479,10 @@ static int netlink_rcv_skb(struct sk_buf
>  		if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
>  			goto skip;
>  
> +		/* Skip control messages */
> +		if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
> +			goto skip;
> +


This looks like it would break nfnetlink, which appears to be
using 0 as smallest message type.
