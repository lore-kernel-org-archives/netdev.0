From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: fix feature changes on devices without ndo_set_features
Date: Fri, 13 Nov 2015 10:30:31 -0800
Message-ID: <56462C47.6010605@gmail.com>
References: <5645C0A5.2080506@cumulusnetworks.com> <1447422841-2333-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jarod Wilson <jarod@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36427 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbbKMSb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 13:31:29 -0500
Received: by pacdm15 with SMTP id dm15so107237190pac.3
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 10:31:29 -0800 (PST)
In-Reply-To: <1447422841-2333-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/11/15 05:54, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> When __netdev_update_features() was updated to ensure some features are
> disabled on new lower devices, an error was introduced for devices which
> don't have the ndo_set_features() method set. Before we'll just set the
> new features, but now we return an error and don't set them. Fix this by
> returning the old behaviour and setting err to 0 when ndo_set_features
> is not present.
> 
> Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
> CC: Jarod Wilson <jarod@redhat.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Ido Schimmel <idosch@mellanox.com>
> CC: Sander Eikelenboom <linux@eikelenboom.it>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks everyone!

> ---
> Sander please feel free to give your Tested-by.
> 
>  net/core/dev.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ab9b8d0d115e..4a1d198dbbff 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6426,6 +6426,8 @@ int __netdev_update_features(struct net_device *dev)
>  
>  	if (dev->netdev_ops->ndo_set_features)
>  		err = dev->netdev_ops->ndo_set_features(dev, features);
> +	else
> +		err = 0;
>  
>  	if (unlikely(err < 0)) {
>  		netdev_err(dev,
> 


-- 
Florian
