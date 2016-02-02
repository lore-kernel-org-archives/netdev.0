From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip-link: remove warning message
Date: Tue, 2 Feb 2016 15:56:51 +1100
Message-ID: <20160202155651.08800af5@samsung9>
References: <1453343029-14580-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33882 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbcBBE47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 23:56:59 -0500
Received: by mail-pf0-f182.google.com with SMTP id o185so91406865pfb.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 20:56:59 -0800 (PST)
In-Reply-To: <1453343029-14580-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jan 2016 02:23:49 +0000
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> the warning was:
> iproute.c:301:12: warning: 'val' may be used uninitialized in this
> function [-Wmaybe-uninitialized]
>    features &= ~RTAX_FEATURE_ECN;
>             ^
> iproute.c:575:10: note: 'val' was declared here
>    __u32 val;
> 	  ^
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  ip/iproute.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index d5e3ebe..afe70e1 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -572,7 +572,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  			mxlock = *(unsigned*)RTA_DATA(mxrta[RTAX_LOCK]);
>  
>  		for (i=2; i<= RTAX_MAX; i++) {
> -			__u32 val;
> +			__u32 val = 0U;
>  
>  			if (mxrta[i] == NULL)
>  				continue;

Your compiler is doing bad dependency analysis.
There is not really a bug here.

It would still be best to initialize to keep broken compilers from causing warning.
