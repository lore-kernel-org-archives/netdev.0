From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 14:10:59 -0700
Message-ID: <20091010211059.GB1927@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <921ca19c0910100117xdb94fcbo43e9b8ffaf4db997@mail.gmail.com> <20091010162703.GB30354@kroah.com> <1255201230.25061.60.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sujit K M <sjt.kar@gmail.com>, Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1255201230.25061.60.camel@localhost>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 10, 2009 at 08:00:30PM +0100, Ben Hutchings wrote:
> On the other hand, the netlink configuration APIs already use ifindex so
> it may be better just to say that the device ioctls are deprecated and
> applications should use netlink.

I thought that is what was already encouraged to happen.

> > > > That is why all distros name network devices based on the only
> > > > deterministic thing they have today, the MAC address. ?I still fail to
> > > > see why you do not like this solution, it is honestly the only way to
> > > > properly name network devices in a sane manner.
> > > 
> > > This is feature that needs to be implemented. As per the rules followed.
> > 
> > This feature is already implemented today, all distros have it.
> 
> No, see below.

Yes, if not, file a bug in your distro, all of the infrastructure is
already in place, and the udev rules and scripts are already written.

> > > > All distros also provide a way to easily rename the network devices, to
> > > > place a specific name on a specific MAC address, so again, this should
> > > > all be solved already.
> > > >
> > > > No matter how badly your BIOS teams mess up the PCI enumeration order :)
> > > 
> > > This is an problem, But I think this can be solved by implementing some of the
> > > routines in the network device.
> > 
> > I don't, see the rules that your distro ships today for persistant
> > network devices, it's already there, no need to change the kernel at
> > all.
> 
> The udev persistent net rules work tolerably well for a single system
> with a stable set of net devices.
> 
> They do not solve the problem Matt's talking about, which is lack of
> consistency between multiple systems, because the initial enumeration
> order is not predictable.

Again, you name the device as a MAC address.  Or something else that the
BIOS exports in a unique manner (PCI slot name, etc.).  That is
consistant.  If not, then fix the BIOS.

> They also result in name changes when a NIC (or motherboard) is swapped.
> For some users, that's fine; for others, it's not.
> 
> The ability to specify NICs by port name or PCI address should solve
> these problems.

That can be done today quite easily.  But note that PCI addresses are
not guaranteed to be stable.  As lots of machines are known to have
happen.

Again, none of this requires any kernel changes today at all, let alone
adding dummy char devices for network devices.

thanks,

greg k-h
