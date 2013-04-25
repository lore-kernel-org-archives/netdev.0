From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] net: tun: release the reference of tun device in tun_recvmsg
Date: Thu, 25 Apr 2013 15:59:42 +0800
Message-ID: <5178E26E.9020308@redhat.com>
References: <201304250822.38944.a.miskiewicz@gmail.com> <1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: a.miskiewicz@gmail.com, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756032Ab3DYH7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 03:59:54 -0400
In-Reply-To: <1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2013 03:59 PM, Gao feng wrote:
> We forget to release the reference of tun device in tun_recvmsg.
> bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
> (tuntap: move socket to tun_file)

Acked-by: Jason Wang <jasowang@redhat.com>

Thanks
>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  drivers/net/tun.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 0c9df2f..dcd0c19 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1471,14 +1471,17 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
>  	if (!tun)
>  		return -EBADFD;
>  
> -	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
> -		return -EINVAL;
> +	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC)) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
>  	ret = tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
>  			  flags & MSG_DONTWAIT);
>  	if (ret > total_len) {
>  		m->msg_flags |= MSG_TRUNC;
>  		ret = flags & MSG_TRUNC ? ret : total_len;
>  	}
> +out:
>  	tun_put(tun);
>  	return ret;
>  }
