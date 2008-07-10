From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/1] netlabel: netlink_unicast calls kfree_skb on error path by itself
Date: Thu, 10 Jul 2008 09:42:49 -0400
Message-ID: <200807100942.49545.paul.moore@hp.com>
References: <1215695484-17519-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:49137 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbYGJNmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 09:42:54 -0400
In-Reply-To: <1215695484-17519-1-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 10 July 2008 9:11:24 am Denis V. Lunev wrote:
> So, no need to kfree_skb here on the error path. In this case we can
> simply return.
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Hi Denis,

Thanks for catching this and fixing it.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/netlabel/netlabel_cipso_v4.c  |    7 +------
>  net/netlabel/netlabel_mgmt.c      |   12 ++----------
>  net/netlabel/netlabel_unlabeled.c |    6 +-----
>  3 files changed, 4 insertions(+), 21 deletions(-)
>
> diff --git a/net/netlabel/netlabel_cipso_v4.c
> b/net/netlabel/netlabel_cipso_v4.c index fdc14a0..9080c61 100644
> --- a/net/netlabel/netlabel_cipso_v4.c
> +++ b/net/netlabel/netlabel_cipso_v4.c
> @@ -584,12 +584,7 @@ list_start:
>  	rcu_read_unlock();
>
>  	genlmsg_end(ans_skb, data);
> -
> -	ret_val = genlmsg_reply(ans_skb, info);
> -	if (ret_val != 0)
> -		goto list_failure;
> -
> -	return 0;
> +	return genlmsg_reply(ans_skb, info);
>
>  list_retry:
>  	/* XXX - this limit is a guesstimate */
> diff --git a/net/netlabel/netlabel_mgmt.c
> b/net/netlabel/netlabel_mgmt.c index 22c1912..44be5d5 100644
> --- a/net/netlabel/netlabel_mgmt.c
> +++ b/net/netlabel/netlabel_mgmt.c
> @@ -386,11 +386,7 @@ static int netlbl_mgmt_listdef(struct sk_buff
> *skb, struct genl_info *info) rcu_read_unlock();
>
>  	genlmsg_end(ans_skb, data);
> -
> -	ret_val = genlmsg_reply(ans_skb, info);
> -	if (ret_val != 0)
> -		goto listdef_failure;
> -	return 0;
> +	return genlmsg_reply(ans_skb, info);
>
>  listdef_failure_lock:
>  	rcu_read_unlock();
> @@ -501,11 +497,7 @@ static int netlbl_mgmt_version(struct sk_buff
> *skb, struct genl_info *info) goto version_failure;
>
>  	genlmsg_end(ans_skb, data);
> -
> -	ret_val = genlmsg_reply(ans_skb, info);
> -	if (ret_val != 0)
> -		goto version_failure;
> -	return 0;
> +	return genlmsg_reply(ans_skb, info);
>
>  version_failure:
>  	kfree_skb(ans_skb);
> diff --git a/net/netlabel/netlabel_unlabeled.c
> b/net/netlabel/netlabel_unlabeled.c index 52b2611..56f8087 100644
> --- a/net/netlabel/netlabel_unlabeled.c
> +++ b/net/netlabel/netlabel_unlabeled.c
> @@ -1107,11 +1107,7 @@ static int netlbl_unlabel_list(struct sk_buff
> *skb, struct genl_info *info) goto list_failure;
>
>  	genlmsg_end(ans_skb, data);
> -
> -	ret_val = genlmsg_reply(ans_skb, info);
> -	if (ret_val != 0)
> -		goto list_failure;
> -	return 0;
> +	return genlmsg_reply(ans_skb, info);
>
>  list_failure:
>  	kfree_skb(ans_skb);



-- 
paul moore
linux @ hp
