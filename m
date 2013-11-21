From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen
 logic
Date: Thu, 21 Nov 2013 09:52:30 -0500
Message-ID: <528E1E2E.20905@gmail.com>
References: <20131121003828.GA32587@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:40893 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab3KUOwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 09:52:34 -0500
Received: by mail-yh0-f52.google.com with SMTP id i72so3279999yha.25
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 06:52:33 -0800 (PST)
In-Reply-To: <20131121003828.GA32587@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2013 07:38 PM, Hannes Frederic Sowa wrote:
> diff --git a/include/linux/net.h b/include/linux/net.h
> index b292a04..4bcee94 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -164,6 +164,14 @@ struct proto_ops {
>  #endif
>  	int		(*sendmsg)   (struct kiocb *iocb, struct socket *sock,
>  				      struct msghdr *m, size_t total_len);
> +	/* Notes for implementing recvmsg:
> +	 * ===============================
> +	 * msg->msg_namelen should get updated by the recvmsg handlers
> +	 * iff msg_name != NULL. It is by default 0 to prevent
> +	 * returning uninitialized memory to user space.  The recvfrom
> +	 * handlers can assume that msg.msg_name is either NULL or has
> +	 * a minimum size of sizeof(struct sockaddr_storage).
             ^^^^^^^

You meant "maximum", right?

-vlad
