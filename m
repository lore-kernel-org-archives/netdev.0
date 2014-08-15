From: wangyufen <wangyufen@huawei.com>
Subject: Re: your netlink permission checks backport to v3.4
Date: Fri, 15 Aug 2014 17:52:08 +0800
Message-ID: <53EDD848.6090709@huawei.com>
References: <20140807.135339.1840856785990746406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140807.135339.1840856785990746406.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/8/8 4:53, David Miller wrote:
> 
> I don't think you properly compile tested this code:
> 
> diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
> index c00e307..b79ce1e 100644
> --- a/net/decnet/dn_dev.c
> +++ b/net/decnet/dn_dev.c
> @@ -440,7 +440,7 @@ int dn_dev_ioctl(unsigned int cmd, void __user *arg)
>  	case SIOCGIFADDR:
>  		break;
>  	case SIOCSIFADDR:
> -		if (!capable(CAP_NET_ADMIN))
> +		if (!netlink_capable(skb, CAP_NET_ADMIN))
>  			return -EACCES;
>  		if (sdn->sdn_family != AF_DECnet)
>  			return -EINVAL;
> 
> There is no "skb" variable in this function.
> 
> I think we're at the point where this backport makes no sense to submit
> to the -stable tree.
> 
> Multiple rounds of attempting to backport these changes has been tries
> and all such attempts have had problems.  Compile problems, authorship
> errors, lack of follow-up bug fixes, etc.
> 
> This is why I did not try to backport these changes to v3.4 and
> earlier.  The possiblity for introducing more regressions is larger
> than the benefit from including these changes.
> 
> Please do not ask me to include this backport into my v3.4 -stable
> series submissions any longer, thank you.
> 
> Sorry.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

I did not open the CONFIG_DECNET option and the code did not build-in.
It's my first time to do backport. I'm ashamed that I made so many mistakes.

Sincerely sorry to trouble you so much.
