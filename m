From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 06 Jul 2008 20:59:05 -0700 (PDT)
Message-ID: <20080706.205905.159207367.davem@davemloft.net>
References: <20080706.155318.46569612.davem@davemloft.net>
	<20080706165655.0783348b@infradead.org>
	<487176A2.6080604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753883AbYGGD7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 23:59:05 -0400
In-Reply-To: <487176A2.6080604@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 07 Jul 2008 09:51:30 +0800

> Arjan van de Ven said the following on 2008-7-7 7:56:
> > +void netdev_drivername(struct net_device *dev, char *buffer, int len)
> > +{
> > +	struct device_driver *driver;
> > +	struct device *parent;
> > +	struct ethtool_drvinfo info;
> > +	const struct ethtool_ops *ops = dev->ethtool_ops;
> > +
> > +	if (len <= 0)
> > +		return;
> > +	buffer[0] = 0;
> > +
> > +	if (ops->get_drvinfo) {
> 
> if (ops && ops->get_drvinfo)

That's right, ethtool_ops could indeed be NULL.  It is not
a mandatory facility.

> > +		memset(&info, 0, sizeof(info));
> > +		info.cmd = ETHTOOL_GDRVINFO;
> > +		ops->get_drvinfo(dev, &info);
> > +		strlcpy(buffer, info.driver, len);
> > +		if (strlen(info.driver) > 0)
> > +			return;
> > +	}
> 
> seems the logic should be:
> if (strlen(info.driver) > 0) {
> 	strlcpy(buffer, info.driver, len);
> 	return;
> }

Also correct.
