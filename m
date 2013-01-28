From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 2/2] netpoll: use the net namespace of
 current process instead of init_net
Date: Mon, 28 Jan 2013 18:33:38 -0500 (EST)
Message-ID: <20130128.183338.211219305250941993.davem@davemloft.net>
References: <1359338121-10897-1-git-send-email-amwang@redhat.com>
	<1359338121-10897-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755587Ab3A1Xdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:33:39 -0500
In-Reply-To: <1359338121-10897-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 28 Jan 2013 09:55:21 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This will allow us to setup netconsole in a different namespace
> rather than where init_net is.
> 
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied but:

> +	if (np->dev_name) {
> +		struct net *net = current->nsproxy->net_ns;
> +		ndev = __dev_get_by_name(net, np->dev_name);
> +	}

I wonder if you should be using task_nsproxy() here.
