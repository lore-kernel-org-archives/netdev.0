From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [NET]: Device mtu/txqlen/ifmap via rtnetlink.
Date: Thu, 26 Aug 2004 02:29:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412D832F.2070003@pobox.com>
References: <200408260506.i7Q56Ebq022683@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch, davem@redhat.com
In-Reply-To: <200408260506.i7Q56Ebq022683@hera.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> @@ -246,6 +268,30 @@
>  
>  	err = -EINVAL;
>  
> +	if (ifm->ifi_flags)
> +		dev_change_flags(dev, ifm->ifi_flags);
> +
> +	if (ida[IFLA_MAP - 1]) {
> +		if (!dev->set_config) {
> +			err = -EOPNOTSUPP;
> +			goto out;
> +		}
> +
> +		if (!netif_device_present(dev)) {
> +			err = -ENODEV;
> +			goto out;
> +		}
> +		
> +		if (ida[IFLA_MAP - 1]->rta_len != RTA_LENGTH(sizeof(struct ifmap)))
> +			goto out;
> +		
> +		err = dev->set_config(dev, (struct ifmap *)
> +				RTA_DATA(ida[IFLA_MAP - 1]));
> +
> +		if (err)
> +			goto out;
> +	}
> +


Why are new calls to deprecated hook ->set_config() being added?

	Jeff
