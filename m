From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Sat, 13 Sep 2014 23:17:55 +0300
Message-ID: <5414A673.4090300@cogentembedded.com>
References: <54137231.3050304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:58026 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbaIMUO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:14:56 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so2269814wes.21
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 13:14:54 -0700 (PDT)
In-Reply-To: <54137231.3050304@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/13/2014 1:22 AM, David L Stevens wrote:

> This patch allows an admin to set the MTU on a sunvnet device to arbitrary
> values between the minimum (68) and maximum (65535) IPv4 packet sizes.

> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> ---
>   drivers/net/ethernet/sun/sunvnet.c |    6 +++++-
>   drivers/net/ethernet/sun/sunvnet.h |    2 +-
>   2 files changed, 6 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index a6418bb..b557ec4 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -751,6 +751,10 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	if (unlikely(!port))
>   		goto out_dropped;
>   +	if (skb->len > port->vio.rmtu) {

    The patch seems somehow spoiled -- there should be no space before +.

> +		goto out_dropped;
> +	}
> +
>   	spin_lock_irqsave(&port->vio.lock, flags);
>    	dr = &port->vio.drings[VIO_DRIVER_TX_RING];

WBR, Sergei
