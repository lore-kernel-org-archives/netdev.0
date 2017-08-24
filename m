From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 6/6] lib/libnetlink: Don't pass NULL
 parameter to memcpy()
Date: Thu, 24 Aug 2017 15:29:43 -0700
Message-ID: <20170824152943.17173f52@xeon-e3>
References: <20170824094131.2963-1-phil@nwl.cc>
        <20170824094131.2963-7-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34052 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753423AbdHXW3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:29:55 -0400
Received: by mail-pg0-f49.google.com with SMTP id a7so3942609pgn.1
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 15:29:55 -0700 (PDT)
In-Reply-To: <20170824094131.2963-7-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Aug 2017 11:41:31 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Both addattr_l() and rta_addattr_l() may be called with NULL data
> pointer and 0 alen parameters. Avoid calling memcpy() in that case.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  lib/libnetlink.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index 874e660be7eb4..fbe719ee10449 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -871,7 +871,8 @@ int addattr_l(struct nlmsghdr *n, int maxlen, int type, const void *data,
>  	rta = NLMSG_TAIL(n);
>  	rta->rta_type = type;
>  	rta->rta_len = len;
> -	memcpy(RTA_DATA(rta), data, alen);
> +	if (alen)
> +		memcpy(RTA_DATA(rta), data, alen);
>  	n->nlmsg_len = NLMSG_ALIGN(n->nlmsg_len) + RTA_ALIGN(len);
>  	return 0;
>  }
> @@ -958,7 +959,8 @@ int rta_addattr_l(struct rtattr *rta, int maxlen, int type,
>  	subrta = (struct rtattr *)(((char *)rta) + RTA_ALIGN(rta->rta_len));
>  	subrta->rta_type = type;
>  	subrta->rta_len = len;
> -	memcpy(RTA_DATA(subrta), data, alen);
> +	if (alen)
> +		memcpy(RTA_DATA(subrta), data, alen);
>  	rta->rta_len = NLMSG_ALIGN(rta->rta_len) + RTA_ALIGN(len);
>  	return 0;
>  }

Ok, applied. You never know when GCC language experts might decide
to exploit undefined behavior.
