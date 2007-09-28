From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] Update get_net_ns_by_pid
Date: Fri, 28 Sep 2007 18:13:54 -0500
Message-ID: <20070928231354.GB7407@sergelap.austin.rr.com>
References: <m1k5qbfo1n.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:48075 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbXI1XOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 19:14:02 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8SNFRPG028452
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 19:15:27 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8SNDx4G662596
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 19:13:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8SNDx5s008783
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 19:13:59 -0400
Content-Disposition: inline
In-Reply-To: <m1k5qbfo1n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> 
> In the -mm tree the rules for access an nsproxy have changed,
> and in get_net_ns_by_pid we access the nsproxy, so update
> it to follow the new rules.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Yup, looks right.

I assume Pavel's Acked-by would actually matter, but still

Acked-by: Serge Hallyn <serue@us.ibm.com>

thanks,
-serge

> ---
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 739fbad..1caba10 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -746,10 +746,10 @@ static struct net *get_net_ns_by_pid(pid_t pid)
>  	rcu_read_lock();
>  	tsk = find_task_by_pid(pid);
>  	if (tsk) {
> -		task_lock(tsk);
> -		if (tsk->nsproxy)
> -			net = get_net(tsk->nsproxy->net_ns);
> -		task_unlock(tsk);
> +		struct nsproxy *nsproxy;
> +		nsproxy = task_nsproxy(tsk);
> +		if (nsproxy)
> +			net = get_net(nsproxy->net_ns);
>  	}
>  	rcu_read_unlock();
>  	return net;
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
