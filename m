From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Wed, 10 Jun 2015 15:25:16 -0600
Message-ID: <5578AB3C.5020206@gmail.com>
References: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, bblanco@plumgrid.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35133 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbbFJVZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 17:25:21 -0400
Received: by igbzc4 with SMTP id zc4so44840630igb.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 14:25:21 -0700 (PDT)
In-Reply-To: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/10/15 2:56 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Fix a BUG() where CONFIG_NET_SWITCHDEV is set but the driver for a bridged
> port does not support switchdec_port_attr_set op.  Don't BUG() if
> -EOPNOTSUPP is returned.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>   net/switchdev/switchdev.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index e008057..99bced4 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -103,7 +103,7 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
>
>   	rtnl_lock();
>   	err = switchdev_port_attr_set(asw->dev, &asw->attr);
> -	BUG_ON(err);
> +	BUG_ON(err && err != -EOPNOTSUPP);
>   	rtnl_unlock();
>
>   	dev_put(asw->dev);
>

Should that be WARN_ON instead of BUG_ON?
