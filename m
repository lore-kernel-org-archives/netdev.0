From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/5] qede: Add support for ethtool private flags
Date: Mon, 18 Apr 2016 17:11:47 +0300
Message-ID: <5714EB23.5020102@cogentembedded.com>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
 <1460921195-23352-3-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yuval Mintz <Yuval.Mintz@qlogic.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36010 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbcDROLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 10:11:50 -0400
Received: by mail-lf0-f51.google.com with SMTP id g184so218201694lfb.3
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 07:11:49 -0700 (PDT)
In-Reply-To: <1460921195-23352-3-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/17/2016 10:26 PM, Yuval Mintz wrote:

> Adds a getter for the interfaces private flags.
> The only parameter currently supported is whether the interface is a
> coupled function [required for supporting 100g].
>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> ---
>   drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 27 +++++++++++++++++++++++++
>   1 file changed, 27 insertions(+)
>
> diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
> index f87e83b..5ba6b2a 100644
> --- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
[...]
> @@ -185,6 +200,17 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
>   	}
>   }
>
> +static u32 qede_get_priv_flags(struct net_device *dev)
> +{
> +	struct qede_dev *edev = netdev_priv(dev);
> +	u32 flags = 0;
> +
> +	flags |= (!!(edev->dev_info.common.num_hwfns > 1)) <<
> +		 QEDE_PRI_FLAG_CMT;

    Why not just '='?

> +
> +	return flags;

    ... or direct return of the value above?

> +}
> +
>   static int qede_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>   {
>   	struct qede_dev *edev = netdev_priv(dev);
[...]

MBR, Sergei
