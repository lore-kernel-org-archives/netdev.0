From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [RFC PATCH 1/1] ethtool: adding support for multiple slave port
 configuration
Date: Mon, 28 Jul 2014 21:03:28 -0400
Message-ID: <20140729010328.GA4683@gospo.home.greyhouse.net>
References: <1406291305-22286-1-git-send-email-mugunthanvnm@ti.com>
 <1406429221.29010.151.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406429221.29010.151.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 27, 2014 at 03:47:01AM +0100, Ben Hutchings wrote:
> On Fri, 2014-07-25 at 17:58 +0530, Mugunthan V N wrote:
> > Some Ethernet Swtich controllers like CPSW in AM335x, TI814x, DRA7x and
> > AM43xx SoCs, Network Coprocessor in AM5K2E0x, Realtek Switch controllers
> > etc has to capability of conneting multiple networks using L2 switching
> > and has multiple phys. With the existing code, ethtool can communicate
> > only to one phy.
> > 
> > To enable user to communicate multiple phy connected to single Ethernet
> > Switch controller, intoducing a optional new parameter in Ethtool interface
> > to pass which slave to set/get the phy configuration.
> 
> There was some discussion about configuration APIs for hardware/firmware
> bridges earlier this year and I thought there was a consensus for
> assigning a network device to each port.  This would remove the need to
> identify ports within a device.  But I may have misremembered.

Using a netdev per port was more or less the concensus for how to handle
the management of the individual ports connected to a hardware/firmware
switch.  Various suggestions were made to add a new struct (or not add
one) to at least link the netdevs used for each port to capture and
describe the hardware/firmware switch.

If individual netdevs are created (even if their functionality is
extremely limited) you could then use those devices with the base switch
driver that exists now, correct?  It seems like this must be an option
as this patch is simply a way to export this data/configuration to
userspace via ethtool.

> 
> > Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> > ---
> >  include/uapi/linux/ethtool.h | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> > index 96ade34..3011427 100644
> > --- a/include/uapi/linux/ethtool.h
> > +++ b/include/uapi/linux/ethtool.h
> > @@ -60,6 +60,9 @@
> >   *	and other link features that the link partner advertised
> >   *	through autonegotiation; 0 if unknown or not applicable.
> >   *	Read-only.
> > + * @slave_port: Specify which slave port to be used to set/get
> > + *	parmeters, for example which slave port phy to be used for
> > + *	set/get phy capabilities
> 
> The difficulty with assigning the reserved fields in struct ethtool_cmd
> is that nothing has ever checked that they are set to 0.  So if we were
> to assign this field and support it in ethtool, someone might run it on
> an older kernel version and all configuration changes will be made to
> port 0 rather than the one they specified.  I don't think it would be
> acceptable to tell users that 'oh, the port number option silently fails
> on older kernel versions'.
> 
> So at the very least you would also need to add some way for userland to
> find out whether the driver will check the value of this field.
> 
> Ben.
> 
> >   * The link speed in Mbps is split between @speed and @speed_hi.  Use
> >   * the ethtool_cmd_speed() and ethtool_cmd_speed_set() functions to
> > @@ -107,7 +110,8 @@ struct ethtool_cmd {
> >  	__u8	eth_tp_mdix;
> >  	__u8	eth_tp_mdix_ctrl;
> >  	__u32	lp_advertising;
> > -	__u32	reserved[2];
> > +	__u32	slave_port;
> > +	__u32	reserved;
> >  };
> >  
> >  static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
> 
> -- 
> Ben Hutchings
> The generation of random numbers is too important to be left to chance.
>                                                             - Robert Coveyou
