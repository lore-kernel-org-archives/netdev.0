From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: linux-wireless mailing list
Date: Thu, 11 Mar 2004 16:12:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040312001200.GA13387@bougret.hpl.hp.com>
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

	Jeff (and others),

	I'm hitting a problem with migrating Wireless Extensions to
RtNetlink.

	The basic model of Wireless Extensions is Query/Reply. I ask
for the ESSID, the card returns the ESSID, I ask for a scan, the card
returns the scan results.
	This doesn't work well with RtNetlink. RtNetlink supports only
Set and Dump. Set doesn't allow to return data, and Dump doesn't take
any input arguments, so always return everything. Using Dump doesn't
make sense, I don't want the card to perform a Wireless Scan every
time I want to check the ESSID (each Wireless Scan takes a few
seconds).
	The RtNetlink interface was clearly not designed for hardware
devices where the retrieval of each piece of information has a
significant cost/overhead.

	I'm also suspicious of the interaction with the device
notifiers and link flag setting. But that may not be as bad.

	The option I'm leaning toward is to define a new Netlink
socket type for Wireless Extensions, which would allow me to use the
Query/Reply model.

	Thanks...

	Jean
