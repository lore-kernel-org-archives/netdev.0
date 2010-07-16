From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
  mapping
Date: Fri, 16 Jul 2010 11:04:07 -0700
Message-ID: <20100716110407.316eb8f1@s6510>
References: <AANLkTinxLy2noL0GcZyVtMsEndxseCr6kkxuvyBNIfHr@mail.gmail.com>
	<1279300205.2097.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chetan Loke <chetanloke@gmail.com>, netdev@vger.kernel.org,
	"Loke, Chetan" <chetan.loke@netscout.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44265 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756651Ab0GPSEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 14:04:13 -0400
In-Reply-To: <1279300205.2097.9.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Jul 2010 18:10:05 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Fri, 2010-07-16 at 09:18 -0400, Chetan Loke wrote:
> [...]
> > Requirement:
> > R1)Ability to address NICs/interfaces using a mac-addr in ioctls. This
> > is required because we don't have a consistent naming scheme for
> > Ethernet devices.Asking customers and/or field-engineers to change
> > udev rules and
> > other config files is not feasible.
> 
> I don't know why they would need to change those.  It might be useful to
> have a simple userland tool that will look up a device name by MAC
> address.  But it's not like a MAC address is any more user-friendly than
> a net device name!
> 
> > Existing pain-points:
> > P1) ioctl needs either i) if-name or ii) if-index before we can invoke
> > bind() etc.This works fine if you know your configuration and it is not going
> > to change.However,if we hot-add a NIC and if you have adapters from multiple
> > vendors(think:driver load order) then upon a reboot,the 'eth'
> > interfaces can be re-mapped.
> 
> As you well know, udev makes the name/MAC-address association
> persistent, so this is no longer a problem.
> 
> [...]
> >   W2.1) If renaming were to even succeed then none of the existing
> > drivers re-register their msix-vectors.
> 
> There is no need to do that, since the IRQ handler names are not copied
> but are held by the driver.  So the driver only needs to rewrite the
> names when the device is renamed.  However that does require registering
> a netdev notifier.  It might be worth adding a netdev operation for
> renaming, to make this easier for driver maintainers.
> 
> [...]
> > But there is no programmatic way of deriving the 'ethX' name.
> [...]
> 
> Deriving it from what?  Are you aiming to determine what the name of a
> device will be before the physical device is installed?
> 
> Ben.
> 

The additional API is not needed. It is trivial to find address for device
and do reverse mapping. Either with ioctl's or /sys/class/net/XXX/addr
