From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 14:13:52 -0700
Message-ID: <20091010211352.GC1927@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <20091010124731.GA17218@mock.linuxdev.us.dell.com> <20091010162518.GA30354@kroah.com> <4AD0C598.4070403@kadzban.is-a-geek.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AD0C598.4070403@kadzban.is-a-geek.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 10, 2009 at 10:34:16AM -0700, Bryan Kadzban wrote:
> Greg KH wrote:
> > On Sat, Oct 10, 2009 at 07:47:32AM -0500, Matt Domsch wrote:
> >> On Fri, Oct 09, 2009 at 10:23:08PM -0700, Greg KH wrote:
> >>> On Fri, Oct 09, 2009 at 11:40:57PM -0500, Matt Domsch wrote:
> >>>> The fundamental roadblock to this is that enumeration !=
> >>>> naming, except that it is for network devices, and we keep
> >>>> changing the enumeration order.
> >>> No, the hardware changes the enumeration order, it places _no_ 
> >>> guarantees on what order stuff will be found in.  So this is not
> >>> the kernel changing, just to be clear.
> >> Over time the kernel has changed its enumeration mechanisms, and 
> >> introduced parallelism into the process (which is a good thing), 
> >> which, from a user perspective, makes names nondeterministic.  Yes,
> >> fixing this up by hard-coding MAC addresses after install has been
> >> the traditional mechanism to address this.  I think there's a
> >> better way.
> > 
> > Ok, but that way can be done in userspace, without the need for this 
> > char device, right?
> 
> For the record -- when I tried to send a patch that did exactly this
> (provided an option to use by-path persistence for network drivers), it
> was rejected because "that doesn't work for USB".
> 
> True, it doesn't.  But by-mac (what we have today) doesn't work for
> replacing motherboards in a random home system (that can't override the
> MAC address in the BIOS), either.

If you replace a motherboard, you honestly expect no configuration to be
needed to be changed?  If so, then don't use the MAC naming scheme for
your systems.

> > But this code is not a requirement to "solve" the fact that network 
> > devices can show up in different order, that problem can be solved as
> > long as the user picks a single way to name the devices, using tools
> > that are already present today in distros.
> 
> This code is not a requirement, no.  But -- as you say -- it does
> provide a halfway-decent way to assign multiple names to a NIC.  And
> that provides admins the choice to use a couple different persistence
> schemes, depending on how they expect their hardware to work.

But the names need to then be resolved back to a "real" kernel name in
order to do anything with that network connection, as the char devices
are not real ones.  So that adds an additional layer of complexity on
all of the system configuration tools.

thanks,

greg k-h
