From: Joe Perches <joe@perches.com>
Subject: Re: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 07:06:24 -0700
Message-ID: <1471961184.3746.92.camel@perches.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Luis Henriques <luis.henriques@canonical.com>,
        Avijit Kanti Das <avijitnsec@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-23 at 14:41 +0100, Luis Henriques wrote:
> From: Avijit Kanti Das <avijitnsec@codeaurora.org>
> 
> memset() the structure ethtool_wolinfo that has padded bytes
> but the padded bytes have not been zeroed out.

I expect there are more of these in the kernel tree.

While this patch is strictly true and the behavior is not
guaranteed by spec, what compilers do not memset then set
the specified member?  Every time I've looked, gcc does.
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
[]
> @@ -1435,11 +1435,13 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
>  
>  static int ethtool_get_wol(struct net_device *dev, char __user *useraddr)
>  {
> -	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
> +	struct ethtool_wolinfo wol;
>  
>  	if (!dev->ethtool_ops->get_wol)
>  		return -EOPNOTSUPP;
>  
> +	memset(&wol, 0, sizeof(struct ethtool_wolinfo));
> +	wol.cmd = ETHTOOL_GWOL;
>  	dev->ethtool_ops->get_wol(dev, &wol);
>  
>  	if (copy_to_user(useraddr, &wol, sizeof(wol)))
