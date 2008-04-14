From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 14:03:37 +0200
Message-ID: <3ae72650804140503g73f8c281w438defb1c6477ba9@mail.gmail.com>
References: <ftdb3v$tls$1@ger.gmane.org> <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Marco d'Itri" <md@linux.it>, "Harald Hoyer" <harald@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1208167737.31695.32.camel@pmac.infradead.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2008 at 12:08 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Mon, 2008-04-07 at 16:38 +0200, Marco d'Itri wrote:
>  > On Apr 07, Harald Hoyer <harald@redhat.com> wrote:
>  >
>  > > So Kazunori Asayama attached a patch to the bugzilla, which modifies
>  > > write_net_rules to take the KERNEL attribute also in account.
>  > >
>  > > What do you think?
>  >
>  > If this were accepted by Kay I would definitely remove it from the
>  > Debian package. It's an ugly hack for a broken device which should not
>  > be generalized.
>
>  Actually it's a generic problem.

Yeah, unfortunately it is.

> It also occurs on OLPC, where the
>  libertas wireless device presents two interfaces with the same MAC
>  address -- the 'eth%d' interface for normal 802.11 wireless, and the
>  'msh%d' interface for mesh. This approach fixes that too. Our previous
>  fix for that was 'TEST=="anycast_mask"' and 'TEST=="lbs_rtap"', which
>  are horridly device-specific hacks.
>
>  It isn't _broken_ to have more than one device on the same host with the
>  same MAC address; it's just unusual.

Yeah, PS3 even had both interfaces with the same MAC named eth*. :)
That got changed recently to make it easier for usersapce.

>  One thing I don't understand: Don't we already emit a KERNEL== criterion
>  in the case where there is already a udev rule 'reserving' the name that
>  the kernel used for the current device? Why is that one OK, and why only
>  in that case? This patch just makes it consistent.

Yes, we do that in the recent udev versions. We only make sure we keep
the enumeration across the same basename, not across different device
names.

>  > Unconditionally adding a KERNEL key means that persistent names will
>  > break if a driver changes the base name (e.g. wlan* -> eth*).
>
>  Drivers shouldn't do that. It'll change the name of the device and may
>  confuse userspace :)

It happens sometimes, that a new driver has a new name, but that is
not neccesarily something we need to cover with the persistent net
names. The main goal is to provide stable names regardless of
module-loading/bus-probe/device-enumeration order, not the use of new
drivers which look different to userspace.

>  One alternative approach would be to use dev->dev_id (is that exported
>  in sysfs?). That's what IPv6 addrconf uses in addition to the MAC
>  address to provide a unique address when MAC addresses are shared.
>
>  We could modify the libertas and gelic (and any other affected) drivers
>  to provide a dev_id, make sure it's exported in sysfs, and then use that
>  in the udev rules. Would that make you happy?
>
>  It has implications w.r.t. the autoconfigured IPv6 addresses of those
>  devices, but I think we can cope with those. I'm probably the only
>  person in the world with an IPv6 address for a PS3 listed in DNS anyway.

Sounds good.

Thanks,
Kay
