From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 02/15] user ns: setns: move capable checks into per-ns
 attach helper
Date: Sat, 3 Sep 2011 18:51:40 -0700
Message-ID: <20110904015140.GB32295@count0.beaverton.ibm.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
 <1314993400-6910-5-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net
To: Serge Hallyn <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42193 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab1IDBvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 21:51:46 -0400
Content-Disposition: inline
In-Reply-To: <1314993400-6910-5-git-send-email-serge@hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2011 at 07:56:27PM +0000, Serge Hallyn wrote:
> From: "Serge E. Hallyn" <serge@hallyn.com>

I was confused about this patch until I realized that you're not
simply "moving" the capability checks but "distributing" them. Then
you're showing that you'll soon change some to nsown_capable() or
ns_capable() using the strange cpp pattern in the snippet below.

At least I think that's what you intended. A commit message would
help :).

Cheers,
	-Matt Helsley

> 
> Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  ipc/namespace.c          |    7 +++++++
>  kernel/fork.c            |    5 +++++
>  kernel/nsproxy.c         |   11 ++++++++---
>  kernel/utsname.c         |    7 +++++++
>  net/core/net_namespace.c |    7 +++++++
>  5 files changed, 34 insertions(+), 3 deletions(-)
> 
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index ce0a647..a0a7609 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -163,6 +163,13 @@ static void ipcns_put(void *ns)
> 
>  static int ipcns_install(struct nsproxy *nsproxy, void *ns)
>  {
> +#if 0
> +	struct ipc_namespace *newns = ns;
> +	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
> +#else
> +	if (!capable(CAP_SYS_ADMIN))
> +#endif
> +		return -1;
>  	/* Ditch state from the old ipc namespace */
>  	exit_sem(current);
>  	put_ipc_ns(nsproxy->ipc_ns);
