From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] iov_iter: don't revert if csum error
Date: Fri, 28 Apr 2017 15:16:31 +0200
Message-ID: <20170428131631.GA22996@bistromath.localdomain>
References: <080dafec-c57f-0546-4d2f-ce4a31222e25@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, pabeni@redhat.com,
        edumazet@google.com, hannes@stressinduktion.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56942 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939820AbdD1NQg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 09:16:36 -0400
Content-Disposition: inline
In-Reply-To: <080dafec-c57f-0546-4d2f-ce4a31222e25@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-28, 20:48:45 +0800, Ding Tianhong wrote:
> The patch 3278682 (make skb_copy_datagram_msg() et.al. preserve
> ->msg_iter on error) will revert the iov buffer if copy to iter
> failed, but it looks no need to revert for csum error, so fix it.
> 
> Fixes: 3278682 ("make skb_copy_datagram_msg() et.al. preserve->msg_iter on error")

Please use 12 digits, ie 327868212381.

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  net/core/datagram.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index f4947e7..475a8e9 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -760,7 +760,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
> 
>  	if (msg_data_left(msg) < chunk) {
>  		if (__skb_checksum_complete(skb))
> -			goto csum_error;
> +			goto fault;

With this patch, skb_copy_and_csum_datagram_msg() will return -EFAULT
for an incorrect checksum, that doesn't seem right.

>  		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
>  			goto fault;
>  	} else {
> -- 
> 1.8.3.1
> 

-- 
Sabrina
