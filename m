From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 1/1] driver: macvtap: Unregister netdev rx_handler if
 macvtap_newlink fails
Date: Fri, 25 Nov 2016 10:48:58 +0800
Message-ID: <a2941cab-03bc-9ff1-9a9e-9ab1af5c861f@redhat.com>
References: <1480039506-29740-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
To: fgao@48lvckh6395k16k5.yundunddos.com, davem@davemloft.net,
        edumazet@google.com, netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44830 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751439AbcKYCtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 21:49:09 -0500
In-Reply-To: <1480039506-29740-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月25日 10:05, fgao@48lvckh6395k16k5.yundunddos.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> The macvtap_newlink registers the netdev rx_handler firstly, but it
> does not unregister the handler if macvlan_common_newlink failed.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>   drivers/net/macvtap.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 070e329..bceca28 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -491,7 +491,13 @@ static int macvtap_newlink(struct net *src_net,
>   	/* Don't put anything that may fail after macvlan_common_newlink
>   	 * because we can't undo what it does.
>   	 */
> -	return macvlan_common_newlink(src_net, dev, tb, data);
> +	err = macvlan_common_newlink(src_net, dev, tb, data);
> +	if (err) {
> +		netdev_rx_handler_unregister(dev);
> +		return err;
> +	}
> +
> +	return 0;
>   }
>   
>   static void macvtap_dellink(struct net_device *dev,

Acked-by: Jason Wang <jasowang@redhat.com>
