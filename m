From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V3] net: add Xilinx emac lite device driver
Date: Wed, 2 Sep 2009 07:33:18 -0600
Message-ID: <20090902133245.5128E26804D@mail202-sin.bigfish.com>
References: <20090820094956.02DFC45004F@mail96-dub.bigfish.com> <20090820094914.46f1db9c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<davem@davemloft.net>, <jgarzik@pobox.com>,
	<grant.likely@secretlab.ca>,
	"Josh Boyer" <jwboyer@linux.vnet.ibm.com>,
	"John Williams" <john.williams@petalogix.com>,
	"Michal Simek" <michal.simek@petalogix.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe002.messaging.microsoft.com ([207.46.51.76]:57742 "EHLO
	SG2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751408AbZIBNdV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 09:33:21 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20090820094914.46f1db9c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Thursday, August 20, 2009 5:49 PM
> To: John Linn
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
davem@davemloft.net; jgarzik@pobox.com; John
> Linn; grant.likely@secretlab.ca; Josh Boyer; John Williams; Michal
Simek; Sadanand Mutyala
> Subject: Re: [PATCH] [V3] net: add Xilinx emac lite device driver
> 
> On Thu, 20 Aug 2009 03:49:51 -0600
> John Linn <john.linn@xilinx.com> wrote:
> 
> > +/**
> > + * xemaclite_ioctl - Perform IO Control operations on the network
device
> > + * @dev:	Pointer to the network device
> > + * @rq:		Pointer to the interface request structure
> > + * @cmd:	IOCTL command
> > + *
> > + * The only IOCTL operation supported by this function is setting
the MAC
> > + * address. An error is reported if any other operations are
requested.
> > + *
> > + * Return:	0 to indicate success, or a negative error for failure.
> > + */
> > +static int xemaclite_ioctl(struct net_device *dev, struct ifreq
*rq, int cmd)
> > +{
> > +	struct net_local *lp = (struct net_local *) netdev_priv(dev);
> > +	struct hw_addr_data *hw_addr = (struct hw_addr_data *)
&rq->ifr_hwaddr;
> > +
> > +	switch (cmd) {
> > +	case SIOCETHTOOL:
> > +		return -EIO;
> > +
> > +	case SIOCSIFHWADDR:
> > +		dev_err(&lp->ndev->dev, "SIOCSIFHWADDR\n");
> > +
> > +		/* Copy MAC address in from user space */
> > +		copy_from_user((void __force *) dev->dev_addr,
> > +			       (void __user __force *) hw_addr,
> > +			       IFHWADDRLEN);
> > +		xemaclite_set_mac_address(lp, dev->dev_addr);
> > +		break;
> > +	default:
> > +		return -EOPNOTSUPP;
> > +	}
> > +
> > +	return 0;
> > +}
> 
> Do you really need this? I doubt the SIOCSIFHWADDR even reaches
driver!
> 
> The normal call path for setting hardware address is:
>   dev_ifsioc
>          dev_set_mac_address
>              ops->ndo_set_mac_address -->
> 
> The driver should be:
>    1. defining new code to do ndo_set_mac_address
>    2. remove existing xmaclite_ioctl - all ioctl's handled by upper
layers
> 
> FYI - the only ioctl's that make it to network device ndo_ioctl
>  are listed in dev_ifsioc
>    SIOCDEVPRIVATE ... SIOCDEVPRIVATE + 15
>    SIOCBOND*
>    SIOCMII*
>    SIOCBR*
>    SIOCHWTSTAMP
>    SIOCWANDEV
> 
> 

We agree and will be updating the driver for this change. Sorry about
the delay as I was on vacation.

Thanks,
John


This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


