From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: Fix module refcount leak in kernel_accept()
Date: Fri, 19 Dec 2008 07:35:37 +0100
Message-ID: <1229668537.17082.15.camel@violet>
References: <494A23FE.6020305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:47214 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbYLSGfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 01:35:48 -0500
In-Reply-To: <494A23FE.6020305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei,

> The kernel_accept() does not hold the module refcount of newsock->ops->owner,
> so we need __module_get(newsock->ops->owner) code after call kernel_accept()
> by hand.
> In sunrpc, the module refcount is missing to hold. So this cause kernel panic.
> 
> Used following script to reproduct:
> 
> while [ 1 ];
> do
>     mount -t nfs4 192.168.0.19:/ /mnt
>     touch /mnt/file
>     umount /mnt
>     lsmod | grep ipv6
> done
> 
> This patch fixed the problem by add __module_get(newsock->ops->owner) to
> kernel_accept(). So we do not need to used __module_get(newsock->ops->owner)
> in every place when used kernel_accept().
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> ---
>  net/bluetooth/rfcomm/core.c |    2 --
>  net/socket.c                |    1 +
>  2 files changed, 1 insertions(+), 2 deletions(-)

I was just about to reply and ask you to double check the users since I
know that I am using that API. Hey, but you already did that. Thanks.

Dave, for what its worth, Acked-by me.

Regards

Marcel


