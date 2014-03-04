From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] tipc: allow connection shutdown callback
 to be invoked in advance
Date: Tue, 04 Mar 2014 13:47:21 -0500 (EST)
Message-ID: <20140304.134721.1392009259805360574.davem@davemloft.net>
References: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
	<1393920343-4134-2-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbaCDSrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:47:24 -0500
In-Reply-To: <1393920343-4134-2-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Tue, 4 Mar 2014 09:05:38 +0100

> @@ -401,7 +401,7 @@ static void cfg_conn_msg_event(int conid, struct sockaddr_tipc *addr,
>  
>  		ret = tipc_conn_sendmsg(&cfgsrv, conid, addr, rep_buf->data,
>  					rep_buf->len);
> -		if (ret < 0)
> +		if (ret == -ENOMEM)
>  			pr_err("Sending cfg reply message failed, no memory\n");
>  
>  		kfree_skb(rep_buf);

Even -ENOMEM doesn't deserve a pr_err() log message.

The memory allocators in the kernel generate log messages on memory allocation
failure, when appropriate, with full stack backtraces.

Please just remove this test entirely, thanks.
