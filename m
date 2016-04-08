From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv6: rework the lock in addrconf_permanent_addr
Date: Fri, 8 Apr 2016 14:50:02 +0300
Message-ID: <57079AEA.3010201@cogentembedded.com>
References: <1460107359-8937-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34169 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbcDHLuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 07:50:06 -0400
Received: by mail-lf0-f52.google.com with SMTP id j11so77192633lfb.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 04:50:04 -0700 (PDT)
In-Reply-To: <1460107359-8937-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/8/2016 12:22 PM, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>
>
> 1. nothing of idev is changed, so read lock is enough
> 2. ifp is changed, so used ifp->lock or cmpxchg to protect it
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/ipv6/addrconf.c | 26 ++++++++++++++++++++------
>   1 file changed, 20 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 27aed1a..f6e7605b 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
[...]
> @@ -3212,7 +3221,12 @@ static int fixup_permanent_addr(struct inet6_dev *idev,
>   		if (unlikely(IS_ERR(rt)))
>   			return PTR_ERR(rt);
>
> -		ifp->rt = rt;
> +		prev = cmpxchg(&ifp->rt, NULL, rt);
> +
> +		/*if cmpxchg failed*/

    Please add spaces after /* and before */

> +		if (prev) {
> +			ip6_rt_put(rt);
> +		}

    {} not needed here, please remove.

[...]

MBR, Sergei
