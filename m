From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 02/39] wimax: declarations for the in-kernel WiMAX API
Date: Mon, 24 Nov 2008 16:12:22 -0800
Message-ID: <20081124161222.10927011@extreme>
References: <cover.1227562829.git.inaky@linux.intel.com>
	<8deda2d5304761622a3744cd3e9a39551490bced.1227562829.git.inaky@linux.intel.com>
	<20081124143326.58fdcbed@extreme>
	<200811241543.33830.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32953 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753991AbYKYAM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 19:12:26 -0500
In-Reply-To: <200811241543.33830.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Nov 2008 15:43:33 -0800
Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:

> On Monday 24 November 2008, Stephen Hemminger wrote:
> > On Mon, 24 Nov 2008 13:50:25 -0800
> >
> > Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:
> > > [...snip...]
> > > + */ 
> > > +struct wimax_dev {
> > > +	struct net_device *net_dev;
> > > +	struct list_head id_table_node;
> > > +	struct list_head pipe_list;
> > > +	struct wimax_pipe *pipe_msg;
> > > +	struct mutex mutex;		/* Protects all members and API calls */
> > > +	enum wimax_st state;
> > > +
> > > +	int (*op_msg_from_user)(struct wimax_dev *wimax_dev,
> > > +				const void *, size_t,
> > > +				const struct genl_info *info);
> > > +	int (*op_rfkill_sw_toggle)(struct wimax_dev *wimax_dev,
> > > +				   enum wimax_rf_state);
> > > +	int (*op_reset)(struct wimax_dev *wimax_dev);
> >
> > Move function pointers separate from data??
> 
> Most devices will have only a single adapter, so I thought it was not worth 
> the overhead of the double dereference when average you will have a single 
> copy.
> 
> > > +	struct genl_family gnl_family;
> >
> > Isn't family for all of wimax not per device?
> 
> Nope, it is per device. One generic netlink family per device (named "WiMAX 
> DEVICENAME"). 
> 
> Makes it very easy in user and kernel space, no need for the overhead of 
> having an extra attribute for the destination interface.
> 
> > > +	struct rfkill *rfkill;
> > > +	struct input_dev *rfkill_input;
> > > +	unsigned rf_hw:1;
> > > +	unsigned rf_sw:1;
> >
> > don't bother with bitfield overhead make them u8
> 
> sure
> 
> > > +	char name[32];
> > > +};
> >
> > Why have name in this data structure? Do you handle network device
> > renames properly?
> 
> This is a physical name, not the network interface name (recommended name in 
> the members documentation is DRIVERNAME:physical path.
> 
> The reason is it is used to register different things (rfkill device, input 
> device for rfkill, threads). It being tied to the physical path makes it easy 
> to map and not vulnerable to renames.
> 
> Now it might be too short, that's another matter.

Then shouldn't it be a 'struct device' and live in sysfs class hierarchy??
