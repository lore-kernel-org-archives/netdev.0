From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 9 Nov 2011 16:34:04 +0000
Message-ID: <1320856444.18929.78.camel@deadeye>
References: <4EA89972.5060101@teksavvy.com>
	  <20111026.194045.2019668159403582571.davem@davemloft.net>
	  <4EA8B283.3010105@teksavvy.com>
	  <20111026.221719.2216112919297458522.davem@davemloft.net>
	  <4EB19BBE.5050602@teksavvy.com> <1320266549.2782.21.camel@bwh-desktop>
	 <4EBAA967.10403@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Mark Lord <kernel@teksavvy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EBAA967.10403@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-09 at 11:25 -0500, Mark Lord wrote:
> On 11-11-02 04:42 PM, Ben Hutchings wrote:
> > On Wed, 2011-11-02 at 15:36 -0400, Mark Lord wrote:
> > [...]
> >> First cut (for review) at updating the in-kernel asix usb/network driver
> >> from the latest vendor GPL version of the driver, obtained from here:
> >>
> >>   http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver
> ..
> >> --- linux-3.0/drivers/net/usb/asix.c	2011-10-12 17:59:03.000000000 -0400
> >> +++ linux/drivers/net/usb/asix.c	2011-11-01 19:00:50.051289683 -0400
> > [...]
> ...
> >> +	.set_tx_csum		= ax88772b_set_tx_csum,
> >> +	.get_tx_csum		= ax88772b_get_tx_csum,
> >> +	.get_rx_csum		= ax88772b_get_rx_csum,
> >> +	.set_rx_csum		= ax88772b_set_rx_csum,
> >> +};
> > 
> > The various ethtool operations for offload flags are being (or have
> > been) removed.  The driver must set net_device::hw_features and
> > implement net_device_ops::ndo_set_features instead.
> 
> Okay, I see what to do for the rx_csum stuff, based on other drivers.
> 
> But is there anything to replace the tx_csum stuff,
> or should I just remove it entirely without a substitute?

If TX checksum offload only needs to be requested in TX descriptors and
not in a configuration register, then you don't need to do anything when
it's enabled or disabled.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
