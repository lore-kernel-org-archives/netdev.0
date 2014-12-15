From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH net-next 1/1] net: Support for switch port
 configuration
Date: Mon, 15 Dec 2014 14:05:19 +0000
Message-ID: <20141215140519.GA21952@casper.infradead.org>
References: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/10/14 at 04:23pm, Varlese, Marco wrote:
> +#ifdef CONFIG_NET_SWITCHDEV
> +static int do_setswcfg(struct net_device *dev, struct nlattr *attr)
> +{
> +	int rem, err = -EINVAL;
> +	struct nlattr *v;
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	nla_for_each_nested(v, attr, rem) {
> +		u32 op = nla_type(v);
> +		u64 value = nla_get_u64(v);
> +
> +		err = ops->ndo_switch_port_set_cfg(dev, op, value);
> +		if (err)
> +			break;
> +	}
> +	return err;
> +}
> +#endif

A strictly technical feedback first: I suggest to split the above into
a validation and commit part to keep Netlink operations atomic. Doing
commit & rollback for the deeply nested configuration we are heading
to will be difficult and error prone. Let's keep updates atomic for as
long as possible, i.e. individual set operations can't fail.
