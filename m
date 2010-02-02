From: Marcel Holtmann <marcel@holtmann.org>
Subject: RE: [PATCH net-next-2.6 09/13] net-caif: add CAIF netdevice
Date: Tue, 02 Feb 2010 06:14:40 -0800
Message-ID: <1265120080.31341.87.camel@localhost.localdomain>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1264028130-14364-10-git-send-email-sjur.brandeland@stericsson.com>
	 <4B580A39.3000805@trash.net>
	 <61D8D34BB13CFE408D154529C120E079032A2145@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	davem@davemloft.net, stefano.babic@babic.homelinux.org,
	randy.dunlap@oracle.com
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:42841 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755943Ab0BBOPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 09:15:30 -0500
In-Reply-To: <61D8D34BB13CFE408D154529C120E079032A2145@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> >> +int chnl_net_ioctl(unsigned int cmd, unsigned long arg, bool
> >> +from_user_land) { +	struct chnl_net *priv;
> >> +	int result = -1;
> >> +	struct chnl_net *dev;
> >> +	struct net_device *netdevptr;
> >> +	int ret;
> >> +	struct ifreq ifreq;
> >> +	struct ifcaif_param param;
> >> +	rtnl_lock();
> >> +	if (from_user_land) {
> >> +		if (copy_from_user(&ifreq, (const void *)arg, sizeof(ifreq)))
> >> +			return -EFAULT; +	} else
> >> +		memcpy(&ifreq, (void *)arg, sizeof(ifreq));
> > 
> > Why do you need both an ioctl and a netlink interface?
> 
> Well, I would like to keep support for both netlink and ioctl.
> Internally we are using a netlink interface, and oFono is using ioctl to create interfaces.

we could try to convert oFono in using netlink. Shouldn't be that hard
as long as it is RTNL. Only the generic netlink is painful in userspace
applications with a mainloop.

Regards

Marcel


