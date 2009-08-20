From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] Expose may_setuid() in user.h and add may_setgid()
	(v2)
Date: Wed, 19 Aug 2009 20:31:53 -0500
Message-ID: <20090820013153.GA5120@us.ibm.com>
References: <1250625435-16299-1-git-send-email-danms@us.ibm.com> <1250625435-16299-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orenl@librato.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:34549 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbZHTBjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 21:39:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7K1YkGU026046
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 19:34:46 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7K1dkRD254104
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 19:39:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7K1dkOU022283
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 19:39:46 -0600
Content-Disposition: inline
In-Reply-To: <1250625435-16299-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> Make these helpers available to others.
> 
> Changes in v2:
>  - Avoid checking the groupinfo in ctx->realcred against the current in
>    may_setgid()
> 
> Cc: Serge Hallyn <serue@us.ibm.com>

Acked-by: Serge Hallyn <serue@us.ibm.com>

> Signed-off-by: Dan Smith <danms@us.ibm.com>
> ---
>  include/linux/user.h |    9 +++++++++
>  kernel/user.c        |   13 ++++++++++++-
>  2 files changed, 21 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/user.h b/include/linux/user.h
> index 68daf84..c231e9c 100644
> --- a/include/linux/user.h
> +++ b/include/linux/user.h
> @@ -1 +1,10 @@
> +#ifndef _LINUX_USER_H
> +#define _LINUX_USER_H
> +
>  #include <asm/user.h>
> +#include <linux/sched.h>
> +
> +extern int may_setuid(struct user_namespace *ns, uid_t uid);
> +extern int may_setgid(gid_t gid);
> +
> +#endif
> diff --git a/kernel/user.c b/kernel/user.c
> index a535ed6..a78fde7 100644
> --- a/kernel/user.c
> +++ b/kernel/user.c
> @@ -604,7 +604,7 @@ int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
>  	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
>  }
> 
> -static int may_setuid(struct user_namespace *ns, uid_t uid)
> +int may_setuid(struct user_namespace *ns, uid_t uid)
>  {
>  	/*
>  	 * this next check will one day become
> @@ -631,6 +631,17 @@ static int may_setuid(struct user_namespace *ns, uid_t uid)
>  	return 0;
>  }
> 
> +int may_setgid(gid_t gid)
> +{
> +	if (capable(CAP_SETGID))
> +		return 1;
> +
> +	if (in_egroup_p(gid))
> +		return 1;
> +
> +	return 0;
> +}
> +
>  static struct user_struct *do_restore_user(struct ckpt_ctx *ctx)
>  {
>  	struct user_struct *u;
> -- 
> 1.6.2.5
