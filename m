From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v3 4/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Mon, 12 Jan 2015 07:26:19 -0500
Message-ID: <20150112122619.GD9213@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150105174910.GA6304@linux>
 <20150105175206.GB6304@linux>
 <20150105175713.GC6304@linux>
 <20150105183131.GD6304@linux>
 <54AE6FC1.6050007@pengutronix.de>
 <20150108151901.GA11398@vivalin-002>
 <54B3B555.5010804@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B3B555.5010804@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 12, 2015 at 12:51:49PM +0100, Marc Kleine-Budde wrote:
> On 01/08/2015 04:19 PM, Ahmed S. Darwish wrote:
> 
> [...]
> 
> >>>  MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
> >>> @@ -463,7 +631,18 @@ static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
> >>>  	if (err)
> >>>  		return err;
> >>>  
> >>> -	dev->fw_version = le32_to_cpu(msg.u.softinfo.fw_version);
> >>> +	switch (dev->family) {
> >>> +	case KVASER_LEAF:
> >>> +		dev->fw_version = le32_to_cpu(msg.u.leaf.softinfo.fw_version);
> >>> +		break;
> >>> +	case KVASER_USBCAN:
> >>> +		dev->fw_version = le32_to_cpu(msg.u.usbcan.softinfo.fw_version);
> >>> +		break;
> >>> +	default:
> >>> +		dev_err(dev->udev->dev.parent,
> >>> +			"Invalid device family (%d)\n", dev->family);
> >>> +		return -EINVAL;
> >>
> >> The default case should not happen. I think you can remove it.
> 
> > It's true, it _should_ never happen. But I only add such checks if
> > the follow-up code critically depends on a certain `dev->family`
> > behavior. So it's kind of a defensive check against any possible
> > bug in driver or memory.
> > 
> > What do you think?
> 
> The kernel is full of callback functions, if you have a bit flip there
> you're in trouble anyways. A bug in the driver (or other parts of the
> kernel) might overwrite the memory of dev->family, but if this happens,
> more things will break.
> 

I see. Thanks for the explanation.

Most of them are now removed in latest submission, except two to
avoid GCC warnings of variables that "may be used uninitialized".

Regards,
Darwish
