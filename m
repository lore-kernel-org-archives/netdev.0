From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 02/17] vbus: add virtual-bus definitions
Date: Thu, 02 Apr 2009 17:06:16 +0100
Message-ID: <1238688376.3202.10.camel@achroite>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
	 <20090331184257.28333.64028.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:46453 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752063AbZDBQGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 12:06:25 -0400
In-Reply-To: <20090331184257.28333.64028.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-31 at 14:42 -0400, Gregory Haskins wrote:
[...]
> +Create a device instance
> +------------------------
> +
> +Devices are instantiated by again utilizing the /config/vbus configfs area.
> +At first you may suspect that devices are created as subordinate objects of a
> +bus/container instance, but you would be mistaken.

This is kind of patronising; why don't you simply lay out how things
_do_ work?

>  Devices are actually
> +root-level objects in vbus specifically to allow greater flexibility in the
> +association of a device.  For instance, it may be desirable to have a single
> +device that spans multiple VMs (consider an ethernet switch, or a shared disk
> +for a cluster).  Therefore, device lifecycles are managed by creating/deleting
> +objects in /config/vbus/devices.
> +
> +Note: Creating a device instance is actually a two step process:  We need to
> +give the device instance a unique name, and we also need to give it a specific
> +device type.  It is hard to express both parameters using standard filesystem
> +operations like mkdir, so the design decision was made to require performing
> +the operation in two steps.

How about exposing a subdir for each device class under
/config/vbus/devices/ and allowing device creation only within those?
Two-stage construction is a pain for both users and implementors.

[...]
> +At this point, we are ready to roll.  Pid 4382 has access to a virtual-bus
> +namespace with one device, id=0.  Its type is:
> +
> +# cat /sys/vbus/instances/beb4df8f-7483-4028-b3f7-767512e2a18c/devices/0/type
> +virtual-ethernet
> +
> +"virtual-ethernet"?  Why is it not "venet-tap"?  Device-classes are allowed to
> +register their interfaces under an id that is not required to be the same as
> +their deviceclass.  This supports device polymorphism.   For instance,
> +consider that an interface "virtual-ethernet" may provide basic 802.x packet
> +exchange.  However, we could have various implementations of a device that
> +supports the 802.x interface, while having various implementations behind
> +them.
[...]

It seems to me that your "device-classes" correspond to drivers and
"interfaces" correspond to device classes in the LDM.  To avoid
confusion, I think the vbus terminology should be made consistent with
LDM.  And certainly these should not both be called simply "type" in the
configfs/sysfs interface.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

