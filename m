From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
  mapping
Date: Fri, 16 Jul 2010 18:10:05 +0100
Message-ID: <1279300205.2097.9.camel@achroite.uk.solarflarecom.com>
References: <AANLkTinxLy2noL0GcZyVtMsEndxseCr6kkxuvyBNIfHr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Loke, Chetan" <chetan.loke@netscout.com>
To: Chetan Loke <chetanloke@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7366 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab0GPRKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 13:10:11 -0400
In-Reply-To: <AANLkTinxLy2noL0GcZyVtMsEndxseCr6kkxuvyBNIfHr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-07-16 at 09:18 -0400, Chetan Loke wrote:
[...]
> Requirement:
> R1)Ability to address NICs/interfaces using a mac-addr in ioctls. This
> is required because we don't have a consistent naming scheme for
> Ethernet devices.Asking customers and/or field-engineers to change
> udev rules and
> other config files is not feasible.

I don't know why they would need to change those.  It might be useful to
have a simple userland tool that will look up a device name by MAC
address.  But it's not like a MAC address is any more user-friendly than
a net device name!

> Existing pain-points:
> P1) ioctl needs either i) if-name or ii) if-index before we can invoke
> bind() etc.This works fine if you know your configuration and it is not going
> to change.However,if we hot-add a NIC and if you have adapters from multiple
> vendors(think:driver load order) then upon a reboot,the 'eth'
> interfaces can be re-mapped.

As you well know, udev makes the name/MAC-address association
persistent, so this is no longer a problem.

[...]
>   W2.1) If renaming were to even succeed then none of the existing
> drivers re-register their msix-vectors.

There is no need to do that, since the IRQ handler names are not copied
but are held by the driver.  So the driver only needs to rewrite the
names when the device is renamed.  However that does require registering
a netdev notifier.  It might be worth adding a netdev operation for
renaming, to make this easier for driver maintainers.

[...]
> But there is no programmatic way of deriving the 'ethX' name.
[...]

Deriving it from what?  Are you aiming to determine what the name of a
device will be before the physical device is installed?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

