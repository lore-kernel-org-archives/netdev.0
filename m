From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: linux-wireless mailing list
Date: Wed, 10 Mar 2004 10:06:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310180602.GB9531@bougret.hpl.hp.com>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com> <40469DA1.9090502@pobox.com> <20040305040352.GA16669@bougret.hpl.hp.com> <404F5461.80000@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <404F5461.80000@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 10, 2004 at 12:46:09PM -0500, Jeff Garzik wrote:
> Jean Tourrilhes wrote:
> >+static inline int rtnetlink_standard_call(struct net_device *	dev,
> >+					  struct iw_event *	request,
> >+					  int			request_len,
> >+					  iw_handler		handler)
> >+{
> >+	const struct iw_ioctl_description *	descr = NULL;
> >+	unsigned int				cmd;
> >+	union iwreq_data *			wrqu;
> >+	int					hdr_len;
> >+	struct iw_request_info			info;
> >+	int					ret = -EINVAL;
> >+
> >+	/* Get the description of the IOCTL */
> >+	cmd = request->cmd;
> >+	if((cmd - SIOCIWFIRST) >= standard_ioctl_num)
> >+		return -EOPNOTSUPP;
> >+	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
> 
> 
> OK, this patch looks good to me.

	Thanks. I'll try to work on the missing parts.

> There is one piece we need to change though, that will cause the size of 
> this patch to increase a bit.
> 
> Look at ethtool_ops, and net/core/ethtool.c, in the current upstream 2.4 
> and 2.6 trees.
> 
> A key goal of mine is to completely eliminate the union and the 
> iw_handler type.  To increase type-safety, and to decrease the pain of 
> going through 32<->64-bit translation layers, each wireless hook needs 
> to have a specific (not generic) interface (a la ethtool_ops).

	The current API is already completely 32<->64-bit
safe. Wireless Tools have been used on Alpha since the end of the
90's. The code to support 32 bit user space on 64 bit kernel was
trivial and concern only a single pointer, and such pointer would not
exist when using RtNetlink. So, I claim that when using RtNetlink, the
API would be entirely 32<->64-bit safe.

	You point about type safety is perfectly valid.
	I believe that this is a tradeoff. The design reason to have a
single type of handler, apart from the space saving, was to allow a
driver to hook a common handler to multiple commands. I've used that
in a few cases, because it made the driver code simpler.
	So far, we never had any problem with regards to type
safety. Maybe it's because wireless driver authors are very clever ;-)

> 	Jeff

	Jean
