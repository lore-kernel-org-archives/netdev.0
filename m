From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: linux-wireless mailing list
Date: Wed, 10 Mar 2004 12:46:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404F5461.80000@pobox.com>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com> <40469DA1.9090502@pobox.com> <20040305040352.GA16669@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040305040352.GA16669@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> +static inline int rtnetlink_standard_call(struct net_device *	dev,
> +					  struct iw_event *	request,
> +					  int			request_len,
> +					  iw_handler		handler)
> +{
> +	const struct iw_ioctl_description *	descr = NULL;
> +	unsigned int				cmd;
> +	union iwreq_data *			wrqu;
> +	int					hdr_len;
> +	struct iw_request_info			info;
> +	int					ret = -EINVAL;
> +
> +	/* Get the description of the IOCTL */
> +	cmd = request->cmd;
> +	if((cmd - SIOCIWFIRST) >= standard_ioctl_num)
> +		return -EOPNOTSUPP;
> +	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);


OK, this patch looks good to me.

There is one piece we need to change though, that will cause the size of 
this patch to increase a bit.

Look at ethtool_ops, and net/core/ethtool.c, in the current upstream 2.4 
and 2.6 trees.

A key goal of mine is to completely eliminate the union and the 
iw_handler type.  To increase type-safety, and to decrease the pain of 
going through 32<->64-bit translation layers, each wireless hook needs 
to have a specific (not generic) interface (a la ethtool_ops).

	Jeff
