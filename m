From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH net-next? 1/1] netlabel: return msg overflow error from netlbl_cipsov4_list faster
Date: Fri, 11 Jul 2008 07:01:05 -0400
Message-ID: <200807110701.05377.paul.moore@hp.com>
References: <1215773149-27728-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:24492 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbYGKLBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 07:01:09 -0400
In-Reply-To: <1215773149-27728-1-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 July 2008 6:45:49 am Denis V. Lunev wrote:
> Currently, we are trying to place the information from the kernel to
> 1, 2, 3 and 4 pages sequentially. These pages are allocated via slab.
> Though, from the slab point of view steps 3 and 4 are equivalent on
> most architectures. So, lets skip 3 pages attempt.
>
> By the way, should we switch from .doit to .dumpit interface here?
> The amount of data seems quite big for me.
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

I'll add my ack to this patch because your logic sounds reasonable and 
I'm glad to have more eyes on the code :)

However, I not a big fan of converting this from a .doit to a .dumpit 
interface because this would cause userspace breakage.  We could 
potentially do both for backwards compatibility but I have no idea if 
it is possible to have both interfaces available at the same time.  One 
thing to keep in mind before diving into your favorite editor is that 
I've yet to hear of there being a problem with this NetLabel command 
and the .doit interface, we may want to hold off to see if it becomes 
an issue.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/netlabel/netlabel_cipso_v4.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/netlabel/netlabel_cipso_v4.c
> b/net/netlabel/netlabel_cipso_v4.c ---
> a/net/netlabel/netlabel_cipso_v4.c
> +++ b/net/netlabel/netlabel_cipso_v4.c
> @@ -591,7 +591,7 @@ list_retry:
>  	if (nlsze_mult < 4) {
>  		rcu_read_unlock();
>  		kfree_skb(ans_skb);
> -		nlsze_mult++;
> +		nlsze_mult *= 2;
>  		goto list_start;
>  	}
>  list_failure_lock:



-- 
paul moore
linux @ hp
