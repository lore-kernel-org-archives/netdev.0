From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: avoid put_cmsg() possible copy longer data than
 input
Date: Wed, 28 Dec 2016 14:48:40 -0500 (EST)
Message-ID: <20161228.144840.961255110231598938.davem@davemloft.net>
References: <1482935663-3428-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751777AbcL1Tsp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:48:45 -0500
In-Reply-To: <1482935663-3428-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Wed, 28 Dec 2016 22:34:23 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> if CMSG_ALIGN(sizeof(struct cmsghdr)) > sizeof(struct cmsghdr),
> original (cmlen - sizeof(struct cmsghdr)) may greater than
> input len.

You are doing a lot of unrelated cleanups in this change.  This
makes it hard to review.

The important parts of the fix seems to be the added checks to make
sure that we don't access the CMSG_DATA() unless we have more than
CMSG_ALIGN(sizeof(struct cmsghdr)) bytes.

I think you can fix that with a few one-line tests rather than
restructuring all of the CMSG_*() macros.

Also:

> @@ -223,7 +223,7 @@ int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
>  	if (MSG_CMSG_COMPAT & msg->msg_flags)
>  		return put_cmsg_compat(msg, level, type, len, data);
>  
> -	if (cm==NULL || msg->msg_controllen < sizeof(*cm)) {
> +	if (cm == NULL || msg->msg_controllen < sizeof(*cm)) {
>  		msg->msg_flags |= MSG_CTRUNC;
>  		return 0; /* XXX: return error? check spec. */
>  	}

This is a coding style fix unrelated to the purpose of this change.

Thanks.
