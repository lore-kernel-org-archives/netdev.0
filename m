From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH net-next 02/11] net: Introduce new api for walking upper
 and lower devices
Date: Mon, 17 Oct 2016 05:21:21 -0700
Message-ID: <20161017052121.2322279d@xeon-e3>
References: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
        <1476494931-31813-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476494931-31813-3-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Oct 2016 18:28:42 -0700
David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org> wrote:

>  
>  /**
> + * netdev_has_upper_dev_all - Check if device is linked to an upper device
> + * @dev: device
> + * @upper_dev: upper device to check
> + *
> + * Find out if a device is linked to specified upper device and return true
> + * in case it is. Note that this checks the entire upper device chain.
> + * The caller must hold rcu lock.
> + */
> +
> +static int __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
> +{
> +	struct net_device *dev = (struct net_device *)data;
> +
> +	if (upper_dev == dev)
> +		return 1;
> +
> +	return 0;
> +}
> +
> +bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
> +				  struct net_device *upper_dev)
> +{
> +	if (netdev_walk_all_upper_dev_rcu(dev, __netdev_has_upper_dev,
> +					  upper_dev))
> +		return true;
> +
> +	return false;
> +}
> +EXPORT_SYMBOL(netdev_has_upper_dev_all_rcu);

You should write this more succinctly as:

static bool __netdev_has_upper_dev(struct net_device *upper_dev, void *data)
{
	struct net_device *dev = data;

	return upper_dev == dev;
}

bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
				  struct net_device *upper_dev)
{
	return netdev_walk_all_upper_dev_rcu(dev,
			__netdev_has_upper_dev, upper_dev);
}

No if/else needed. No cast of void * ptr need. Use const if possible?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
