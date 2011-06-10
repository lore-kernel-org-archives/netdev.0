From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] sctp: kzalloc() error handling on deleting last address
Date: Fri, 10 Jun 2011 16:21:51 +0800
Message-ID: <4DF1D41F.6010300@cn.fujitsu.com>
References: <F8A1B797-89A2-4AAA-AFB1-9B187AC08456@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57548 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753630Ab1FJIXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 04:23:09 -0400
In-Reply-To: <F8A1B797-89A2-4AAA-AFB1-9B187AC08456@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From 49a66ecad72af8c367b125c695a113d3f3870320 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Fri, 10 Jun 2011 16:42:14 +0900
> Subject: [PATCH] sctp: kzalloc() error handling on deleting last address
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
>  net/sctp/socket.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index e7e1b14..a23d898 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -786,6 +786,8 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  				continue;
>  			asoc->asconf_addr_del_pending =
>  			    kzalloc(sizeof(union sctp_addr), GFP_ATOMIC);
> +			if (asoc->asconf_addr_del_pending == NULL) 
> +				continue;

better to return with ENOMEM.

if (asoc->asconf_addr_del_pending == NULL) {
	retval = -ENOMEM;
	goto out;
}


>  			asoc->asconf_addr_del_pending->sa.sa_family =
>  				    addrs->sa_family;
>  			asoc->asconf_addr_del_pending->v4.sin_port =
