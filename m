From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Thu, 11 Jun 2009 03:02:48 +0100
Message-ID: <1244685768.4616.22.camel@deadeye>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@cam.org
To: Martin Fuzzey <mfuzzey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41186 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754949AbZFKCCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 22:02:55 -0400
In-Reply-To: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-10 at 19:34 +0200, Martin Fuzzey wrote:
> Allow network drivers to be configured by the kernel
> in the same way as the userspace "ethtool" program as suggested
> by Nicolas Pitre in a recent mailing list discussion.
> 
> Two methods are possible, selected by KConfig:
> 
> 1) Kernel parameter (net_ethconfig.ethtool)
> which accepts (most of) the same arguments as "ethtool -s"
> 
> 	net_ethconfig.ethtool="eth0 speed 10 duplex full"
> 
> The wol, sopass and msglvl parameters are not (yet?) supported.

Who needs this feature?  Why not use ethtool in an initramfs?

> 2) Programatic configuration via a new function
> neteth_configure_interface() (typically from board specific setup code):
> 
> #include <linux/net-ethconfig.h>
> static struct neteth_if_config force_10mbps = {
> 	.etool_cmd = {
> 		.speed = SPEED_10,
> 		.duplex = DUPLEX_FULL,
> 	},
> 	.set_flags = NETCONF_SET_SPEED | NETCONF_SET_DUPLEX,
> };
> ...
> neteth_configure_interface("eth0", &force_10mbps);
> 
> The programatic method may be required in certain embedded situations
> (for example when different hardware revisions require different
> configurations and the hardware revision can be detected by software).
[...]

Forcing speed and duplex is occasionally needed to work around a link
partner that doesn't implement autonegotiation correctly.  I don't see
that it should ever be needed in platform configuration.  If the driver
doesn't detect the MAC/PHY capabilities correctly then the driver should
be fixed.  Overriding the settings once will not prevent an unsupported
mode being selected later.

I can see that it may be useful to set the PHY type and address from
platform code, but I don't know how many drivers for current hardware
can cope with having those changed after initialisation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
