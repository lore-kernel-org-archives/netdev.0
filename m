From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 2/2] xfrm: force a garbage collection after deleting
 a policy
Date: Thu, 23 May 2013 23:29:58 +0400
Message-ID: <519E6E36.4070600@cogentembedded.com>
References: <20130523185659.19212.56853.stgit@localhost> <20130523190746.19212.6027.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, omoris@redhat.com,
	pwouters@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:49846 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758248Ab3EWT3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 15:29:53 -0400
Received: by mail-lb0-f170.google.com with SMTP id t13so3859452lbd.29
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 12:29:51 -0700 (PDT)
In-Reply-To: <20130523190746.19212.6027.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/23/2013 11:07 PM, Paul Moore wrote:

> In some cases after deleting a policy from the SPD the policy would
> remain in the dst/flow/route cache for an extended period of time
> which caused problems for SELinux as its dynamic network access
> controls key off of the number of XFRM policy and state entries.
> This patch corrects this problem by forcing a XFRM garbage collection
> whenever a policy is sucessfully removed.
>
> Reported-by: Ondrej Moris <omoris@redhat.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>
> ---
>   include/net/xfrm.h     |    6 ++++++
>   net/key/af_key.c       |    4 ++++
>   net/xfrm/xfrm_policy.c |    3 ++-
>   net/xfrm/xfrm_user.c   |    2 ++
>   4 files changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index ae16531..918e4cd 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
[...]
> @@ -1194,6 +1196,10 @@ static inline int xfrm6_policy_check_reverse(struct sock *sk, int dir,
>   {
>   	return 1;
>   }
> +static inline void xfrm_garbage_collect(struct net *net)
> +{
> +	return;

     Not needed.

> +}
>   #endif
>   
>   static __inline__
>

WBR, Sergei
